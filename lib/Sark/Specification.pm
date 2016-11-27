package Sark::Specification;

# ABSTRACT: Repository build specification

use warnings;
use strict;
use Exporter 'import';

use Data::Rx;
use Sark::RxType::Atom;
use Sark::RxType::Boolean;
use Sark::RxType::DockerImage;
use Sark::RxType::Overlay;
use Sark::RxType::RemoteOverlay;
use Sark::RxType::Repository;
use Hash::Merge qw( merge );
use YAML::Tiny;

my @EXPORT_OK = qw( _add_missing_defaults _make_dense_spec _override_single );

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

Initializes the specification object, including setting up the schema
for the spec file validation.

=cut

sub initialize {
    my $self = shift;

    my $rx = Data::Rx->new(
        {   sort_keys    => 1,
            prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::Atom
                    Sark::RxType::Boolean
                    Sark::RxType::DockerImage
                    Sark::RxType::Overlay
                    Sark::RxType::RemoteOverlay
                    Sark::RxType::Repository
                    )
            ],
        }
    );

    # Define the schema used to validate the specifcation

    my $sparse_spec = {
        type     => '//rec',
        required => {
            'repository' => {
                type     => '//rec',
                required => { description => '//str', },
                optional => {
                    maintenance => {
                        type     => '//rec',
                        optional => {
                            check_diffs            => '/sark/bool',
                            clean_cache            => '/sark/bool',
                            keep_previous_versions => '//int',
                            remove                 => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/atom',
                            },
                        }
                    }
                }
            },
            'build' => {
                type     => '//rec',
                required => {
                    target => {
                        type     => '//arr',
                        contents => 'tag:sabayon.org:sark/atom',
                    },
                },
                optional => {
                    qa_checks => '/sark/bool',
                    overlays  => {
                        type     => '//arr',
                        contents => 'tag:sabayon.org:sark/overlay',
                    },
                    injected_target => {
                        type     => '//arr',
                        contents => 'tag:sabayon.org:sark/atom',
                    },
                    equo => {
                        type     => '//rec',
                        optional => {
                            repositories => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/repository',
                            },
                            remove_repositories => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/repository',
                            },
                            enman_self => '/sark/bool',
                            no_cache   => '/sark/bool',
                            package    => {
                                type     => '//rec',
                                optional => {
                                    install => {
                                        type => '//arr',
                                        contents =>
                                            'tag:sabayon.org:sark/atom',
                                    },
                                    remove => {
                                        type => '//arr',
                                        contents =>
                                            'tag:sabayon.org:sark/atom',
                                    },
                                    mask => {
                                        type => '//arr',
                                        contents =>
                                            'tag:sabayon.org:sark/atom',
                                    },
                                    unmask => {
                                        type => '//arr',
                                        contents =>
                                            'tag:sabayon.org:sark/atom',
                                    },
                                },
                            },
                            repository => {
                                type => '//any',
                                of   => [
                                    { type => '//str', value => 'main' },
                                    { type => '//str', value => 'weekly' },
                                ],
                            },
                            dependency_install => {
                                type     => '//rec',
                                optional => {
                                    enable                => '/sark/bool',
                                    install_atoms         => '/sark/bool',
                                    dependency_scan_depth => '//int',
                                    prune_virtuals        => '/sark/bool',
                                    install_version       => '/sark/bool',
                                    split_install         => '/sark/bool',
                                },
                            },
                        },
                    },
                    emerge => {
                        type     => '//rec',
                        optional => {
                            default_args  => '//str',
                            split_install => '/sark/bool',
                            features      => '//str',
                            profile       => {
                                type => '//any',
                                of   => [
                                    { type => '//str' },
                                    { type => '//num' },
                                ],
                            },
                            jobs              => '//num',
                            preserved_rebuild => '/sark/bool',
                            skip_sync         => '/sark/bool',
                            webrsync          => '/sark/bool',
                            remote_overlay    => {
                                type     => '//arr',
                                contents => '/sark/remote_overlay',
                            },
                            remove_remote_overlay => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/overlay',
                            },
                            remove_layman_overlay => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/overlay',
                            },
                            remove => {
                                type     => '//arr',
                                contents => 'tag:sabayon.org:sark/atom',
                            },
                        },
                    },
                    docker => {
                        type     => '//rec',
                        optional => {
                            image         => '/sark/docker_image',
                            entropy_image => '/sark/docker_image',
                        },
                    },
                },
            },
        },
    };

    my $dense_spec = _make_dense_spec($sparse_spec);
    print YAML::Tiny::Dump($dense_spec);

    $self->{sparse_schema} = $rx->make_schema($sparse_spec);
    $self->{dense_schema}  = $rx->make_schema($dense_spec);
}

=method validate( $document, $sparse=1 )

Takes the specification C<document> as a string, and confirms that it is
syntactically valid against the specification. The C<sparse> paramter
determines whether to do sparse validation (which doesn't require all
directives to be set), or dense validation (all directives must be set).

Sparse validation is done for build specification files, and dense
validation for cache files.

Throws an exception if the document fails to validate.

=cut

sub validate {
    my $self     = shift;
    my $document = shift;
    my $sparse   = shift // 1;

    if ($sparse) {
        my $result = $self->{sparse_schema}->assert_valid($document);
    }
    else {
        my $result = $self->{dense_schema}->assert_valid($document);
    }
}

=method parse_spec( $document, $sparse=1 )

This is the main function for loading in a specification from a string. It will:

=over 4

=item  Parse the document into a data structure

=item If sparse, will:

=over 4

=item Validate the sparse structure

=item Merge in any defaults to make dense

=item Merge in any overrides

=back

=item Validate the dense document

=item Store the result in this specification object

=back
  
=cut

sub parse_spec {
    my $self     = shift;
    my $document = shift // "";
    my $sparse   = shift // 1;

    my $data = YAML::Tiny::Load($document);

    if ($sparse) {
        $self->validate($data);
        $data = _make_dense_spec($data);
        $data = _add_missing_defaults($data);
    }

    $self->validate( $data, 0 );

    $self->{spec} = $data;
}

=method load_from_spec_file( $filename )

Loads a sparse specification file from disk and automatically
calls C<parse_spec> to parse and convert to a dense spec.

=cut

sub load_from_spec_file {
    my $self = shift;
    my $filename = shift or die "Required filename missing";

    my $contents;
    do {
        local $/;
        open FILE, $filename or die "Couldn't open file: $!";
        $contents = <FILE>;
        close FILE;
    };

    $self->parse_spec( $contents, 1 );
}

=method load_from_cache_file

Loads a dense specification file from disk and automatically
calls C<parse_spec> to parse and validate the contents.

=cut

sub load_from_cache_file {
    my $self = shift;
    my $filename = shift or die "Required filename missing";

    my $contents;
    do {
        local $/;
        open FILE, $filename or die "Couldn't open file: $!";
        $contents = <FILE>;
        close FILE;
    };

    $self->parse_spec( $contents, 0 );
}

=method override_from_environment

Updates the current loaded specification with any overrides specified by
environment variables. Only a subset of the build spec settings can be
overridden using the environment, those which are needed to configure a build
server, or that might need to be changed on manual runs to repair damage.

=cut

sub override_from_environment {
    my $self = shift;

    _override_single( $self->{spec}->{repository}->{maintenance},
        'check_diffs', $ENV{CHECK_BUILD_DIFFS} );
    _override_single( $self->{spec}->{repository}->{maintenance},
        'clean_cache', $ENV{CLEAN_CACHE} );
    _override_single( $self->{spec}->{build}->{docker},
        'image', $ENV{DOCKER_IMAGE} );
    _override_single( $self->{spec}->{build}->{docker},
        'entropy_image', $ENV{DOCKER_EIT_IMAGE} );
    _override_single( $self->{spec}->{build}->{equo},
        'no_cache', $ENV{ETP_NOCACHE} );
    _override_single( $self->{spec}->{build}->{emerge},
        'default_args', $ENV{EMERGE_DEFAULT_ARGS} );
    _override_single( $self->{spec}->{build}->{emerge},
        'features', $ENV{FEATURES} );
    _override_single( $self->{spec}->{build}->{emerge},
        'profile', $ENV{BUILDER_PROFILE} );
    _override_single( $self->{spec}->{build}->{emerge},
        'webrsync', $ENV{WEBRSYNC} );
}

=method save_to_cache_file

Writes out the current specification in dense YAML format to the provided
cache filename.

=cut

sub save_to_cache_file {
    my $self = shift;
    my $filename = shift or die "Required filename missing";

    YAML::Tiny::DumpFile( $filename, $self->{spec} );

}

=func _make_dense_spec( $sparse_spec )

Converts a sparse specification (which might have optional fields) into
a dense one where the same fields are present but are all required.

=cut

sub _make_dense_spec {
    my $sparse_spec = shift // {};

    my $result = {};

    for my $key ( keys( %{$sparse_spec} ) ) {
        my $result_key = $key;
        if ( $key eq 'optional' ) {
            $result_key = 'required';
        }

        if ( $result_key eq 'required' ) {
            if ( !defined $result->{$result_key} ) {
                $result->{$result_key} = {};
            }

            for my $field ( keys( %{ $sparse_spec->{$key} } ) ) {
                if ( ref( $sparse_spec->{$key}->{$field} ) ) {
                    $result->{$result_key}->{$field} =
                        _make_dense_spec( $sparse_spec->{$key}->{$field} );
                }
                else {
                    $result->{$result_key}->{$field} =
                        $sparse_spec->{$key}->{$field};
                }
            }

        }
        else {
            $result->{$result_key} = $sparse_spec->{$key};
        }
    }

    return $result;
}

=fund _add_missing_defaults( $spec )

Populates the given specification with any missing values using hardcoded
defaults.

=cut

sub _add_missing_defaults {
    my $spec = shift || {};

    my $defaults = YAML::Tiny::Load(<<END);
repository:
  maintenance:
    check_diffs: true
    clean_cache: false
    keep_previous_versions: 1
    remove: []
build:
  qa_checks: false
  overlays: []
  injected_target: []
  equo:
    repositories: []
    remove_repositories: []
    enman_self: false
    no_cache: true
    package:
      install: []
      remove: []
      mask: []
      unmask: []
    repository: main
    dependency_install:
      enable: true
      install_atoms: true
      dependency_scan_depth: 2
      prune_virtuals: true
      install_version: false
      split_install: false
  emerge:
    default_args: "--accept-properties=-interactive --verbose --oneshot --complete-graph --buildpkg"
    split_install: false
    features: "parallel-fetch protect-owned compressdebug splitdebug -userpriv"
    profile: 3
    jobs: 1
    preserved_rebuild: false
    skip_sync: false
    webrsync: false
    remote_overlay: []
    remove_remote_overlay: []
    remove_layman_overlay: []
    remove: []
  docker:
    image: "sabayon/builder-amd64"
    entropy_image: "sabayon/eit-amd64"
END

    return merge( $spec, $defaults );
}

=func _override_single( $spec, $env )

Replaces the setting with the given environment variable if present.

=cut

sub _override_single {
    my $spec = shift // {};
    my $setting = shift or die "Required paramter missing";
    my $env = shift // undef;

    if ( defined($env) ) {
        $spec->{$setting} = $env;
    }
}

1;

__END__

=head1 DESCRIPTION

The specification defines how a build should be run, what packages should be built, and how old packages are cleaned up. The specification can be loaded from one of two places:

=over

=item C<Build> specification and environment variables

The build specification is a C<.yaml> file found in the repository directory. This is a sparsely populated document, which can contain some of the build settings, can rely on hardcoded defaults for anything missing, and can be overridden by environment variables during the build.

=item C<Cache> file

Once the build specification has been processed at the start of a run it will be cached into a specification cache file. This can be used by subsequent phases of the build and can be consumed by separate processes (e.g. inside a container when doing clean builds).

The cache file is a source of truth for the build; it is densely populated with all configuration settings for the build and is not overriden by environment variables. This document can be used to reliably repeat a build under a different environment.

=back

=head1 BUILD SPECIFICATION FILE

The build specification file is a yaml document with the following structure. Almost all directives are optional, only the C<repository description> and C<build target> directives are required.

For boolean directives, C<true>, C<on>, C<enabled> and C<1> are all acceptable truthy values, whereas C<false>, C<off>, C<disabled> and C<0> are all acceptable falsy values.

=over 2

=item C<repository>

=over 2

=item C<description> [REQUIRED]

A brief (one-line) description of the repository being created.

Example:

  repository:
    description: My testing repository


=item C<maintenance>

=over 2

=item C<check_diffs>

Enable or disable checking checksum differences of packages from binhost.

Default value is true, acceptable values are boolean. When disabled, all packages are injected into the repository which will result in frequent unnecessary updates for end users.

=item C<clean_cache>

Throw away all cached data for the repository and build a completely clean copy.

Defaults to false, acceptable values are boolean. When enabled, repository builds will be very slow as everything will be done from scratch every build.

This option might be needed if cached data for repository becomes corrupted in some way. 

=item C<keep_previous_versions>

The number of previous package versions to be kept in the repository. For example, if you have C<app/foo-1>, C<app/foo-2> and C<app/foo-3> is built when C<keep_previous_versions> is set to C<2>, then C<app/foo-1> (being the oldest version) will be removed.

Defaults to one, acceptable values are positive integers.

=item C<remove>

A list of packages that should be removed manually from the repository.

Empty by default, meaning no packages are removed. Packages not present in the repository will be silently ignored.

Example:

  repository:
    maintenance:
      remove:
        - app-foo/bar
        - app-misc/baz-1.2

=back

=back

=back

=over 2

=item C<build>

=over 2

=item C<target> [REQUIRED]

A list of valid portage atoms that should be compiled and added to the entropy repository.

Example:

  build:
    target:
      - app-foo/bar
      - =app-foo/baz-1.2

=item C<injected_target>

A list of valid portage atoms that should be compiled as binpkg and not installed inside the build environment, and then injected into the repository.

This option might be needed when multiple conflicting packages need to be built and added to the repository at the same time, which could not be installed concurrently inside the build environment.

=item C<qa_checks>

Whether or not to enable repoman checks on overlays.

Defaults to false, acceptable values are boolean.

=item C<overlays>

A list of layman overlays which should be installed inside the build environment before the compilation phase is run.

Defaults to an empty list.

Example:

  build:
    overlays:
      - sabayon-distro

=item C<equo>

=over 2

=item C<repositories>

A list of extra SCR repositories that should be installed inside the build environment before the compile phase. This might be necessary if you have related repositories and want to avoid making the same package available in all.

Defaults to an empty list. Example:

  build:
    equo:
      repositories:
        - community

=item C<remove_repositories>

A list of previously installed SCR repositories that should be removed from the build environment before the compile phase.

Defaults to an empty list. Example:

  build:
    equo:
      repositories:
        - community

=item C<enman_self>

Whether or not to make the current repository available inside the build environment for the compile phase. This option can be useful to reduce build times by allowing a previously built version of the package to satisfy dependency installs on a subsequent build.

=item C<no_cache>

Whether or not to enable the disk caches (for portage tree, portage and entropy distfiles).

Defaults to true, acceptable values are boolean. 

=item C<package>

=over 2

=item C<install>

A list of entropy packages that should be installed prior to the compile phase. This might be necessary if some packages don't specify all their dependencies correctly.

Defaults to an empty list. Example:

  build:
    equo:
      package:
        install:
          - app/foo
          - app/bar-1

=item C<remove>

A list of entropy packages that should be removed prior to the compile phase. This might be necessary if some packages conflict.

Defaults to an empty list. Example:

  build:
    equo:
      package:
        install:
          - app/foo

=item C<mask>

A list of entropy package masks that should be applied in the build environent before the compile phase. This will present matching entropy package being installed to satisfy a dependency during the compile phase.

Any valid entropy mask atom is acceptable here, see C</etc/entropy/packages/package.db.mask.example> for examples.

=item C<unmask>

A list of entropy package unmasks that should be applied in the build environent before the compile phase. This will present matching entropy package being installed to satisfy a dependency during the compile phase.

Any valid entropy mask atom is acceptable here, see C</etc/entropy/packages/package.db.unmask.example> for examples.

=back

=item C<repository>

Which repository should be used as the base repository for installing equo packages within the build environment (both the manually specified packages listed above, but also those installed for dependencies during the compile phase).

Defaults to C<main> (sabayonlinux.org), acceptable values are C<main>, C<weekly>. You should not change this setting unless you know what you are doing.

=item C<dependency_install>

=over 2

=item C<enabled>

Whether or not dependencies for the targets should be installed via entropy where available. 

Defaults to true, acceptable values are boolean.

=item C<install_atoms>

Whether to install dependencies using unversioned atoms. If set to c<true>, an unversioned atom will be installed (e.g. C<app/foo>). If set to C<false>, the fully versioned atom will be installed as specified in the depending package ebuild (e.g. C<< >=app/foo-1 >>).

Defaults to true, acceptable values are boolean.

=item C<dependency_scan_depth>

How many levels deep through the package dependency tree for each target should be considered for installion using Entropy.

Defaults to 2, acceptable values are positive integers.

=item C<prune_virtuals>

Whether depedencies of virtual packages should be pruned. This is useful to avoid installing unnecessary packages. For example, if a target depends on C<virtual-mta>, the second level of dependencies will include every MTA package that satisfies the virtual; without this option set, all of those MTA packages would be installed one by one (each substituting the previous one) which will waste a lot of time.

Defaults to true, acceptable values are boolean. You should not change this setting unless you know what you are doing.

=item C<install_version>

Whether to install dependencies using unversioned atoms. If set to c<false>, an unversioned atom will be installed (e.g. C<app/foo>). If set to C<false>, the fully versioned atom will be installed as specified in the depending package ebuild (e.g. C<< >=app/foo-1 >>).

Defaults to false, acceptable values are boolean.

=item C<split_install>

Whether to install packages via entropy using separate install commands, or as a single list of packages. When set to C<true>, each package will be installed individually, meaning failure to install one package won't prevent others from being installed. When set to C<false>, all packages are installed in one go which can be quicker, but a failure may cause none to be installed.

Defaults to false, acceptable values are boolean.

=back

=back

=item C<emerge>

=over 2

=item C<default_args>

String of options passed to all emerge install comands.

Defaults to "--accept-properties=-interactive --verbose --oneshot --complete-graph --buildpkg". If changing this setting, it's highly recommended to keep all of the default arguments present to keep the build working as expected. That is you may add additional arguments, but it's not recommended to remove any.

=item C<split_install>

Whether to install packages via portage during the compile phase using separate install commands, or as a single list of packages. When set to C<true>, each package will be installed individually, meaning failure to install one package won't prevent others from being installed. When set to C<false>, all packages are installed in one go which can be quicker, but a failure may cause none to be installed.

Defaults to false, acceptable values are boolean.

=item C<features>

List of portage features to enable during the compile phase.

Defaults to "parallel-fetch protect-owned compressdebug splitdebug -userpriv".

=item C<profile>

Name or number of an eselect profile entry to use inside the build environment. This will be set using eselect at the start of the build. If changing this setting, it may also be necessary to clean the cache to ensure consistency.

Defaults to 3. Acceptable values can be found using C<eselect profile list>.

=item C<jobs>

The number of portage installs that can be done concurrently when the C<parallel> feature is enabled.

Defaults to 1, acceptable values are positive integers.

=item C<preserved_rebuild>

Whether or not to run an emerge of preserved libs after the build.

Defaults to false, acceptable values are boolean.

=item C<skip_sync>

Whether or not to skip the portage sync. This setting might be useful if doing local development work and frequent rebuilds to save time, but should be disabled for normal production builds.

Default is false, acceptable values are boolean.

=item C<webrsync>

Whether to use C<emerge --webrsync> instead of C<emerge --sync>. This option might be useful if you have a high latency connection or are behind a proxy.

Defaults to false, acceptable values are boolean.

=item C<remote_overlay>

A list of non-layman overlays that need to be installed inside the build environment. Each entry should be of the form:

  "name|protocol|url"
  
Defaults to an empty list.
  
Example:

  build:
    emerge:
      remote_overlay:
        - myoverlay|git|https://github.com/foo/bar

=item C<remove_remote_overlay>

A list of previously installed non-layman overlays that need to be removed prior to the build. This should only be the name of the overlay, matching what was used to install it using the C<remote_overlay> setting above.

Example:

  build:
    emerge:
      remove_remote_overlay:
        - myoverlay

=item C<remove_layman_overlay>

A list of previously installed layman overlays that need to be removed prior to the build.

Defaults to an empty list.

=item C<remove>

A list of valid portage atoms which should be removed before the compile phase. This setting might be useful if a conflicting package is pulled in during an earlier phase which would prevent a target from being built.

Defaults to an empty list.

=back

=item C<docker>

The following settings only apply when using the C<Docker> build engine.

=over 2

=item C<image>

Name of the docker image to use for the build environment.

Defaults to "sabayon/builder-amd64".

=item C<entropy_image>

Name of the docker image to use for the repository editing environment.

Defaults to "sabayon/eit-amd64"

=back

=back

=back

=cut
