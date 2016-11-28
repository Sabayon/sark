package Sark::Repo;

# ABSTRACT: Repository representation and management

use warnings;
use strict;

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
    my $sark = Sark->new();
    
    my $logger = Log::Log4perl->get_logger('Sark::Repo');

    my $repo_dir = $sark->{config}->{data}->{repositories}->{definitions};
    if (-d $repo_dir) {
        opendir(my $dh, $repo_dir) or die "Cannot open repositories directory: $!";
        my @repos = grep { ! /^\./ && -d "$repo_dir/$_" } readdir($dh);
        closedir $dh;
        
        return sort(@repos);
    } else {
        $logger->error("Failed to list repositories: no such file or directory: $repo_dir");
    }
    
}

=method enabled

Returns a list of all enabled repository names

=cut

sub enabled {
    my $class = shift;

    my $sark = Sark->new();

}

=method disabled

Returns a list of all disabled repository names

=cut

sub disabled {
    my $class = shift;

    my $sark = Sark->new();

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
