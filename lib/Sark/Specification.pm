package Sark::Specification;
# ABSTRACT: Repository build specification

use warnings;
use strict;

use Data::Rx;

=method load_from_spec_file

=cut
sub new {
    my $class = shift;
    
    my $self = {}
    bless $self, $class;
    
    $self->initialize();
    
    return $self;
}

=method initialize

=cut
sub initialize {
    my $self = shift;

}

=method validate

=cut
sub validate {
    my $self = shift;

}

=method load_from_spec_file

=cut
sub load_from_spec_file {
    my $self = shift;
}

=method override_from_environment

=cut
sub override_from_environment {
    my $self = shift;
    
}

=method load_from_cache_file

=cut
sub load_from_cache_file {
    my $self = shift;

}

=method save_to_cache_file

=cut
sub save_to_cache_file {
    my $self = shift;

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

Defaults to true, acceptable values are boolean. This value should be left enabled unless you know what you are doing.

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

=item C<remove_repositories>

=item C<enman_self>

=item C<no_cache>

=item C<package>

=over 2

=item C<install>

=item C<remove>

=item C<mask>

=item C<unmask>

=back

=item C<repository>

=item C<dependency_install>

=over 2

=item C<enabled>

=item C<install_atoms>

=item C<dependency_scan_depth>

=item C<prune_virtuals>

=item C<install_version>

=item C<split_install>

=back

=back

=item C<emerge>

=over 2

=item C<default_args>

=item C<split_install>

=item C<features>

=item C<profile>

=item C<jobs>

=item C<preserved_rebuild>

=item C<skip_sync>

=item C<webrsync>

=item C<remote_overlay>

=item C<remove_remote_overlay>

=item C<remove_layman_overlay>

=item C<remove>

=back

=item C<docker>

=over 2

=item C<image>

=item C<entropy_image>

=back

=back

=back

=cut
