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
            repositories => {
                type     => '//rec',
                optional => {
                    definitions  => '//str',
                    url          => '//str',
                    signing_keys => '//str',
                },
            },
            phases => {
                type     => '//rec',
                optional => {
                    clean    => '/sark/bool',
                    publish  => '/sark/bool',
                    metadata => '/sark/bool',
                    deploy   => '/sark/bool',
                },
            },
            build => {
                type     => '//rec',
                optional => {
                    engines => {
                        type     => '//arr',
                        contents => '//str',
                    },
                },
            },
            docker => {
                type     => '//rec',
                optional => {
                    commit_images => '/sark/bool',
                    push_images   => '/sark/bool',
                    capabilities  => {
                        type     => '//arr',
                        contents => '//str',
                    },
                    entrypoint => '//str',
                    opts       => '//str',
                    volumes    => {
                        type   => '//map',
                        values => '//str',
                    },
                },
            },
            caches => {
                type     => '//rec',
                optional => {
                    entropy_artifacts => '//str',
                    entropy_packages  => '//str',
                    portage_artifacts => '//str',
                    portage_packages  => '//str',
                    portage_tree      => '//str',
                },
            },
            notification => {
                type     => '//rec',
                optional => {
                    irc => {
                        type     => '//rec',
                        optional => {
                            enabled => '/sark/bool',
                            ident   => '//str',
                            nick    => '//str',
                            server  => '//str',
                            port    => '//str',
                            channel => '//str',
                        },
                    },
                }
            }
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
    if ( -f $filename ) {
        do {
            local $/;
            open FILE, $filename or die "Couldn't open file: $!";
            $contents = <FILE>;
            close FILE;
        };
    } else {
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
repositories:
  definitions: "$ENV{HOME}/sark/repositories"
  url: "https://github.com/Sabayon/community-repositories.git"
phases:
  clean: true
  publish: true
  metadata: true
  deploy: false
build:
  engines:
    - Docker
docker:
  commit_images: true
  push_images: true
  capabilities:
    - SYS_PTRACE
  entrypoint: "/usr/sbin/builder"
  opts: ""
  volumes: {}
caches:
  entropy_artifacts: "$ENV{HOME}/sark/cache/entropy_artifacts"
  entropy_packages: "$ENV{HOME}/sark/cache/entropy_packages"
  portage_artifacts: "$ENV{HOME}/sark/cache/portage_artifacts"
  portage_packages: "$ENV{HOME}/sark/cache/portage_packages"
  portage_tree: "$ENV{HOME}/sark/cache/portage_tree"
notification:
  irc:
    enabled: false
    ident: "bot sabayon scr builder"
    nick: "SCRBuilder"
    server: "irc.freenode.org"
    port: 6667
    channel: "#sabayon-infra"
END

    return merge( $config, $defaults );
}

=func override_from_environment( $config )

Updates the given configuration with any overrides specified by
environment variables. 

=cut

sub _override_from_environment {
    my $config = shift // {};

    _override_single( $config->{repositories},
        'definitions', $ENV{SARK_REPOSITORY_DEFINITIONS} );
    _override_single( $config->{repositories},
        'url', $ENV{REPOSITORY_SPECS} );
    _override_single( $config->{build},
        'engine', split( ' ', $ENV{SARK_BUILD_ENGINE} ) );

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

=item C<signing_keys>

The path to the directory containing the sark repository signing keys.
These keys will be created automatically on first use, but it's important
to keep these keys safe and secure.

=back

=item C<phases>

The following build phases are optional and can be enabled or disabled
globally as desired.

=over 2

=item C<clean>

Enables or disables the clean phase (which removes unwanted and outdated
packages).

Defaults to C<true>, acceptable values are boolean.

=item C<publish>

Enables or disables the publish phase (which generates the repository
metadata). If this phase is disabled, portage artifacts will be compiled
but they won't be converted into entropy packages and put into a repo.

Defaults to C<true>, acceptable values are boolean.

=item C<metadata>

Enables or disables generation of repository metadata (e.g. package lists,
and the web page search database). If you're using Sark for personal
repositories, you may not need this section (but will not hurt to have it
enabled). It is intended for use with the SCR infrastructure.

Defaults to C<true>, acceptable values are boolean.

=item C<deploy>

Enables or disables the deploy phase, which pushes completed builds out to
another server via rsync. If you pull updates from the remote server, this
phase can be safey disabled.

Defaults to C<false>, acceptable values are boolean.

=back

=item C<build>

=over 2

=item C<engine>

The list of engines which should be loaded to run builds.
At the moment only the C<Docker> engine is provided, but this option
remains to allow for future expansion. Each engine will be signalled when
each build phase needs to be run. It's up to the build engine to only
run appropriate build actions, and up to the user to ensure the correct
combination of engines are loaded.

Defaults to a list containing just C<Docker>.

Can be overridden using the C<SARK_BUILD_ENGINE> environment variable.

=back

=item C<docker>

The following settings apply only when using the docker backend for Sark
builds and control how docker is used globally.

=over 2

=item C<commit_images>

Enables or disables committing docker images after each phase completes.

Each build stage (clean, compile, publish) is done in a clean docker
environment, which produces a new disk layer. If the C<commit_images>
setting is enabled, this layer is preserved such that the next time the
build is run, any work done here is saved and reused. This can enable
quicker builds by reducing the amount of re-work, but isn't free. The
disk layers stack up, consuming disk space and eventually need to be
squashed back down to a single layer to free up space which is itself
a time consuming task.

Defaults to C<true>, acceptable values are boolean. It's recommended
this setting be left as-is as long as the image squshing is done
regularly.

=item C<push_images>

Enables or disables pushing docker images to dockerhub.

Pushing images to dockerhub allows for backup and disaster recovery.
Images are pulled back down from dockerhub during the preparation phase.

Defaults to C<true>, acceptable values are boolean.

=item C<capabilities>

A list of additional
[https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities](capabilities)
that need to be enabled on the docker containers. This may be necessary
when certain builds require interacting with the kernel in new ways.

Defaults to the following list:

=over 2

=item C<SYS_PTRACE>

=back

Valid values are anything permitted by docker's C<--cap-add> argument,
and these will passed straight through to docker without being
validated by Sark.

=item C<entrypoint>

The entrypoint to be called inside the docker container. By default,
this will be C<sark> itself, but for development/diagnostic purposes
you may need to alter to change how the build is run inside the container.

Defaults to C</usr/sbin/builder>.

=item C<opts>

A string of custom options to be passed through to the C<docker run>
commands. This is intended to be used for development and debugging only.

Defaults to C<"">, acceptable value is any string of valid docker options.

=item C<volumes>

A hash of additional docker volumes that should be exposed to the build
containers, for example, if you need to expose a custom copy of sark for
development purposes inside the container to be used in conjunction with
the C<entrypoint> setting.

Example:

  docker:
    entrypoint: "/home/foo/sark"
    volumes:
      "/home/foo/sark": "/home/foo/sark"

Defaults to an empty hash. Acceptable values is a hash of external
directories to container mountpoints.

=back

=item C<caches>

=over 2

=item C<entropy_artifacts>

Path to the directory containing cached entropy artifacts for all
repositories.

Defaults to C<$HOME/sark/cache/entropy_artifacts>.

=item C<entropy_packages>

Path to the directory containing cached entropy package downloads for all
repositories.

Defaults to C<$HOME/sark/cache/entropy_packages>.

=item C<portage_artifacts>

Path to the directory containing cached portage artifacts for all
repositories.

Defaults to C<$HOME/sark/cache/portage_artifacts>.

=item C<portage_packages>

Path to the directory containing cached portage package downloads for all
repositories.

Defaults to C<$HOME/sark/cache/portage_packages>.

=item C<portage_tree>

Path to the directory containing the cached portage tree shared across
all repository builds. If you use portage on the build host, you Could
point this to C</usr/portage>.

Defaults to C<$HOME/sark/cache/portage_tree>.

=back

=item C<notification>

=over 2

=item C<irc>

=over 2

=item C<enabled>

Enables or disables irc notifications.

Defaults to C<false>.

=item C<ident>

The IRC ident string used for the notification bot.

Defaults to C<bot sabayon scr builder>.

=item C<nick>

The IRC nickname for the notification bot. This is suffixed with a
random number to avoid conflicts.

Defaults to C<SCRBuilder>

=item C<server>

The IRC server to connect to.

Defaults to C<irc.freenode.org>

=item C<port>

The TCP port number to connect to the IRC server on.

Defaults to C<6667>.

=item C<channel>

The IRC channel to send notification messages in.

Defaults to C<#sabayon-infra>

=back

=back

=back

=cut
