package Sark::Utils::Gentoo;

# ABSTRACT: Gentoo-ish utility functions

use base qw(Exporter);
use Sark::Utils qw(uniq filewrite);
use File::Path qw(make_path);

our @EXPORT_OK =
    qw(add_portage_repository package_deps strip_version return_strip_version detect_useflags);

# Input: package, depth, and atom. Package: sys-fs/foobarfs, Depth: 1 (depth of the package tree) , Atom: 1/0 (enable disable atom output)
my %package_dep_cache;

sub package_deps {
    my $package = shift;
    my $depth   = shift // 1;   # defaults to 1 level of depthness of the tree
    my $atom    = shift // 0;

# Since we expect this sub to be called multiple times with the same arguments, cache the results
    $cache_key = "${package}:${depth}:${atom}";

    if ( !exists $package_dep_cache{$cache_key} ) {
        my @dependencies =
            qx/equery -C -q g --depth=$depth $package/;    #depth=0 it's all
        chomp @dependencies;

# If an unversioned atom is given, equery returns results for all versions in the portage tree
# leading to duplicates. The sanest thing to do is dedup the list. This gives the superset of all
# possible dependencies, which isn't perfectly accurate but should be good enough. For completely
# accurate results, pass in a versioned atom.
        @dependencies = uniq(
            sort
                grep {$_}
                map { $_ =~ s/\[.*\]|\s//g; &strip_version($_) if $atom; $_ }
                @dependencies
        );

        $package_dep_cache{$cache_key} = \@dependencies;
    }

    return @{ $package_dep_cache{$cache_key} };
}

# Input : complete gentoo package (sys-fs/foobarfs-1.9.2)
# Output: stripped form (sys-fs/foobarfs)
sub strip_version { s/-[0-9]{1,}.*$//; }

# Same again as a function
sub return_strip_version { my $p = shift; $_ = $p; strip_version; return $_; }

sub detect_useflags
{ # Detect useflags defined as [-alsa,avahi] in atom, and fill $hash within the $target sub-hash
    my (@packs) = @_;
    my $res;
    for my $i ( 0 .. $#packs ) {
        if ( $packs[$i] =~ /\[(.*?)\]/ ) {
            my $flags = $1;
            $packs[$i] =~ s/\[.*?\]//g;
            $res->[$i] =
                [ +split( /,/, $flags ) ];
        }
    }
    return $res;
}

sub add_portage_repository {
    my $repos_conf_dir = $_[0];
    my $repo           = $_[1];
    my $reponame;
    my $sync_type;
    my @repodef = split( /\|/, $repo );
    ( $reponame, $repo ) = @repodef if ( @repodef == 2 );
    ( $reponame, $sync_type, $repo ) = @repodef if ( @repodef == 3 );

    # try to detect sync-type
    if ( !$sync_type ) {
        $sync_type = ( split( /\:/, $repo ) )[0];
        $sync_type = "git"
            if $repo =~ /github|bitbucket/
            or $sync_type eq "https"
            or $sync_type eq "http";
        $sync_type = "svn" if $repo =~ /\/svn\//;
    }
    $reponame = ( split( /\//, $repo ) )[-1] if !$reponame;
    $reponame =~ s/\.|//g;    #clean
    make_path($repos_conf_dir) if ( !-d $repos_conf_dir );

    filewrite(
        ">", "$repos_conf_dir/$reponame.conf", "[$reponame]
location = /usr/local/overlay/$reponame
sync-type = $sync_type
sync-uri = $repo
auto-sync = yes"
    );
}

1;
