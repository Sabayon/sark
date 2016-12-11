package Sark::Repo;

# ABSTRACT: Repository representation and management

use warnings;
use strict;

use Array::Utils qw(array_minus);

use Sark;

=method sync

Fetches and merges any changes to the repository configuration from
git.

=cut

sub sync {
    my $class = shift;

    my $sark = Sark->new();

}

=method list 

Returns a list of all available repository names

=cut

sub list {
    my $class = shift;
    my $sark  = Sark->new();

    my $logger = Log::Log4perl->get_logger('Sark::Repo');

    my $repo_dir = $sark->{config}->{data}->{repositories}->{definitions};
    if ( -d $repo_dir ) {
        opendir( my $dh, $repo_dir )
            or die "Cannot open repositories directory: $!";
        my @repos = grep { !/^\./ && -d "$repo_dir/$_" } readdir($dh);
        closedir $dh;

        return sort(@repos);
    }
    else {
        $logger->error(
            "Failed to list repositories: no such file or directory: $repo_dir"
        );
    }

}

=method enabled

Returns a list of all enabled repository names

=cut

sub enabled {
    my $self = shift;

    my @all_repos      = $self->list;
    my @disabled_repos = $self->disabled;
    my @enabled_repos  = array_minus( @all_repos, @disabled_repos );

    return @enabled_repos;
}

=method disabled

Returns a list of all disabled repository names

=cut

sub disabled {
    my $self = shift;

    my $sark = Sark->new();

    return sort( @{ $sark->{state}->{data}->{disabled_repositories} } );
}

=method enable_repos( @repos, $persist=1 )

Enables the given repositories by name, suitable for bulk operations.

This method will remove the named repositories from the disabled repositories
state file, and if the persist option is set, will trigger a save of
the state file.

=cut

sub enable_repos {
    my $self      = shift;
    my $repo_list = shift;
    my @repos     = @{$repo_list};
    my $persist   = shift // 1;

    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Repo::enable_repos');

    # Optimise, grab the list of all repos up front
    my %all_repos = map { $_ => 1 } Sark::Repo->list;

    # Mark which ones are disabled to start with
    for ( Sark::Repo->disabled ) {
        $all_repos{$_} = 0;
    }

    # Maintain a count of changes made, to see if we need to flush the state
    # file back to disk.
    my $changes = 0;

    for my $repo (@repos) {
        unless ( defined( $all_repos{$repo} ) ) {
            $logger->warn("Unknown repository '$repo'");
            next;
        }

        if ( $all_repos{$repo} ) {
            $logger->warn("Repository '$repo' is already enabled");
            next;
        }

        # Mark the repository as enabled locally
        $logger->info("Enabling repository '$repo'");
        $all_repos{$repo} = 1;
        ++$changes;
    }

    if ($changes) {

        # Flush the changes back to the disabled repos list
        $sark->{state}->{data}->{disabled_repositories} =
            [ sort( grep { $all_repos{$_} == 0 } keys(%all_repos) ) ];

        if ($persist) {

            # Write the save file back out to disk
            $sark->{state}->save;
        }
    }
}

=method disable_repos( @repos, $persist=1 )

Disables the given repositories by name, suitable for bulk operations.

This method will add the named repositories to the disabled repositories
state file, and if the persist option is set, will trigger a save of
the state file.

=cut

sub disable_repos {
    my $self      = shift;
    my $repo_list = shift;
    my @repos     = @{$repo_list};
    my $persist   = shift // 1;

    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Repo::disable_repos');

    # Optimise, grab the list of all repos up front
    my %all_repos = map { $_ => 1 } Sark::Repo->list;

    # Mark which ones are disabled to start with
    for ( Sark::Repo->disabled ) {
        $all_repos{$_} = 0;
    }

    # Maintain a count of changes made, to see if we need to flush the state
    # file back to disk.
    my $changes = 0;

    for my $repo (@repos) {
        unless ( defined( $all_repos{$repo} ) ) {
            $logger->warn("Unknown repository '$repo'");
            next;
        }

        if ( !$all_repos{$repo} ) {
            $logger->warn("Repository '$repo' is already disabled");
            next;
        }

        # Mark the repository as disabled locally
        $logger->info("Disabling repository '$repo'");
        $all_repos{$repo} = 0;
        ++$changes;
    }

    if ($changes) {

        # Flush the changes back to the disabled repos list
        $sark->{state}->{data}->{disabled_repositories} =
            [ sort( grep { $all_repos{$_} == 0 } keys(%all_repos) ) ];

        if ($persist) {

            # Write the save file back out to disk
            $sark->{state}->save;
        }
    }
}

=method new( $name, $sparse )

Returns a new C<Sark::Repo> instance for the named repository.

Takes two parameters, the C<name> of the repository to represent as a
string, and a C<sparse> boolean, which dictates whether the build
specification is read from the sparse build specification file (when
C<true>), or from the dense cache file (when C<false>, if such a cache
exists).

=cut

sub new {
    my $class  = shift;
    my $name   = shift or die "Required name parameter missing";
    my $sparse = shift // 1;

    my $self = { name => $name };
    bless $self, $class;

    $self->initialize($sparse);

    return $self;
}

=method initialize

=cut

sub initialize {
    my $self = shift;
    my $sparse = shift or die "Required sparse parameter missing";

    $self->{sark} = Sark->new();
}

=method enable

Enables the current repository by removing it from the disabled
repositories list (if present). Does nothing if the repository
is already enabled.

Enabled repositories are included when building all repositories.

=cut

sub enable {
    my $self = shift;

}

=method disable

Disables the current repository by adding it to the disabled
repositories list (if not already present). Does nothign if the
repository is already disabled.

Disabled repositories are not included when building all repositories,
but can still be built manually on demand.

=cut

sub disable {
    my $self = shift;

}

1;

=head1 DESCRIPTION

This class manages available repositories, including listing,
enabling and disabling builds, and triggering builds.
