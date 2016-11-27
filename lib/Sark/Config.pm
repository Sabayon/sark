package Sark::Config;

# ABSTRACT: Sark configuration file handler

use warnings;
use strict;
use Exporter 'import';

use Data::Rx;
use Sark::RxType::Boolean;
use Sark::RxType::Repository;
use Hash::Merge qw( merge );
use YAML::Tiny;

my @EXPORT_OK =
    qw( _add_missing_defaults _override_from_environment _override_single );

=method new

=cut

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    $self->initialize();

    return $self;
}

=method initialize

Initializes the configuration object, including setting up the schema
for the config file validation.

=cut

sub initialize {
    my $self = shift;

    my $rx = Data::Rx->new(
        {   sort_keys    => 1,
            prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::Boolean
                    Sark::RxType::Repository
                    )
            ],
        }
    );

    # Define the schema used to validate the configuration

    my $config = {
        type     => '//rec',
        optional => {
            'repositories' => {
                type     => '//rec',
                optional => {
                    definitions => '//str',
                    url         => '//str',
                },
            },
        },

    };

    $self->{schema} = $rx->make_schema($config);
}

=method validate( $document )

Takes the configuration C<document> as a string, and confirms that it is
syntactically valid against the schema.

Throws an exception if the document fails to validate.

=cut

sub validate {
    my $self     = shift;
    my $document = shift;

    my $result = $self->{schema}->assert_valid($document);
}

=method parse_spec( $document )

This is the main function for loading in a configuration data from a string.
It will:

=over 4

=item  Parse the document into a perl data structure

=item Merge in any defaults

=item Merge in any overrides from the environment

=item Validate the document against the schema

=item Store the result in this config object

=back
  
=cut

sub parse_config {
    my $self = shift;
    my $document = shift // "";

    my $data = YAML::Tiny::Load($document);

    $data = _add_missing_defaults($data);

    $self->validate($data);

    $self->{data} = $data;
}

=method load_from_config_file( $filename )

Loads a configuration file from disk and calls C<parse_config> to handle
parsing and validating the data.

=cut

sub load_from_config_file {
    my $self = shift;
    my $filename = shift or die "Required filename parameter missing";

    my $contents;
    do {
        local $/;
        open FILE, $filename or die "Couldn't open file: $!";
        $contents = <FILE>;
        close FILE;
    };

    $self->parse_config($contents);
}

=fund _add_missing_defaults( $config )

Populates the given configuration data with any missing values using
hardcoded defaults.

=cut

sub _add_missing_defaults {
    my $config = shift || {};

    my $defaults = YAML::Tiny::Load(<<END);
repositories:
  definitions: "$ENV{HOME}/sark/repositories"
  url: "https://github.com/Sabayon/community-repositories.git"
END

    return merge( $config, $defaults );
}

=func override_from_environment

Updates the given configuration with any overrides specified by
environment variables. 

=cut

sub _override_from_environment {
    my $config = shift // {};

    _override_single( $config->{repositories},
        'definitions', $ENV{SARK_REPOSITORY_DEFINITIONS} );
    _override_single( $config->{repositories},
        'url', $ENV{REPOSITORY_SPECS} );

    return $config;
}

=func _override_single( $config, $setting, $value )

Replaces the value of C<setting> in C<config> with the given value if present.
It's expected that C<value> will be an environment variable, which may not be
defined.

Example:

  $config->_override_single( $config, 'key', $ENV{KEY} );

=cut

sub _override_single {
    my $config = shift // {};
    my $setting = shift or die "Required setting paramter missing";
    my $value = shift // undef;

    if ( defined($value) ) {
        $config->{$setting} = $value;
    }
}

1;

__END__

=head1 DESCRIPTION

The configuration file controls how Sark should be run. The available
settings are described below. This defaults to C<~/sark/config.yaml>
but can be overridden when calling L<sark>.

=head1 SARK CONFIGURATION FILE

The Sark configuration file is a yaml document with the following structure.
All settings are optional and will revert to sensible defaults if not
specified. Many settings can also be passed via environment variables,
which will take precedence over the content of the configuration file.

For boolean directives:

C<true>, C<on>, C<enabled> and C<1> are all acceptable for C<true>
C<false>, C<off>, C<disabled> and C<0> are all acceptable for C<false>

=over 2

=item C<repositories>

=over 2

=item C<definitions>

The path to the directory containing the sark repository definition.
This may be a git working directory which the user running L<sark> has
acccess to pull any changes into, to keep automated builds up to date.

=item C<url>

The URL for the git repository containing the sark repository definitions.

=back

=back

=cut
