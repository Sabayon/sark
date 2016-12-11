
package Sark::State;

# ABSTRACT: Sark state file handler

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
    my $state_file = shift or die "Required state_file parameter missing";

    my $self = { STATE_FILE => $state_file };
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

    # Define the schema used to validate the state data

    my $config = {
        type     => '//rec',
        optional => {
            disabled_repositories => {
                type     => '//arr',
                contents => '/sark/repository',
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

This is the main function for loading in state data from a string.

=cut

sub parse_config {
    my $self = shift;
    my $document = shift // "";

    my $data = YAML::Tiny::Load($document);

    $data = _add_missing_defaults($data);

    $self->validate($data);

    $self->{data} = $data;
}

=method load

Helper method, invokes load_from_state_file using the filename set
during initialisation.

=cut

sub load {
    my $self = shift;
    return $self->load_from_state_file( $self->{STATE_FILE} );
}

=method load_from_state_file( $filename )

Loads a configuration file from disk and calls C<parse_config> to handle
parsing and validating the data.

=cut

sub load_from_state_file {
    my $self = shift;
    my $filename = shift or die "Required filename parameter missing";

    my $contents;
    if ( -f $filename ) {
        do {
            local $/;
            open FILE, $filename or die "Couldn't open file: $!";
            $contents = <FILE>;
            close FILE;
        };
    }
    else {
        $contents = '';
    }

    $self->parse_config($contents);
}

=func _add_missing_defaults( $config )

Populates the given configuration data with any missing values using
hardcoded defaults.

=cut

sub _add_missing_defaults {
    my $config = shift || {};

    my $defaults = YAML::Tiny::Load(<<END);
disabled_repositories: []
END

    return merge( $config, $defaults );
}

=method save

Helper method, invokes save_to_state_file using the filename set
during initialisation.

=cut

sub save {
    my $self = shift;
    return $self->save_to_state_file( $self->{STATE_FILE} );
}

=method save_to_state_file

Writes out the current state file in YAML format to the provided
state filename.

=cut

sub save_to_state_file {
    my $self = shift;
    my $filename = shift or die "Required filename missing";

    YAML::Tiny::DumpFile( $filename, $self->{data} );
}

1;

__END__

=head1 DESCRIPTION

The state file stores runtime state data used by sark. This is similar
to the configuration file, but contains settings that will be modified
by sark itself rather than the end user directly. The file may contain
settings that affect the runtime behaviour of sark (e.g. disabling
certain builds temporarily), or runtime progress information that
can be read by other tools to see what Sark is currently doing.

The state file defaults to C<~/sark/state.yaml> but can be overridden
when calling L<sark> to use a different file. If the file is missing,
or deleted, sark will revert to normal behaviour.

The available settings are described below.

=head1 SARK STATE FILE

The Sark state file is a yaml document with the following structure.
All settings are optional and will revert to sensible defaults if not
specified.

For boolean directives:

C<true>, C<on>, C<enabled> and C<1> are all acceptable for C<true>
C<false>, C<off>, C<disabled> and C<0> are all acceptable for C<false>

=over 2

=item C<disabled_repositories>

A list of repositories that should not be built by this instance of
sark. This might be useful if a repository build is causing issues
or known to be broken temporarily. When building everything, repositories
in this list are removed.

=back

=cut

