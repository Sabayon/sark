#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;

use Sark;
use Sark::Utils::Gentoo
    qw(add_portage_repository detect_useflags strip_version return_strip_version);

use Test::More;
use Test::TempDir::Tiny;

subtest "add_portage_repository" => sub {

    my $dir = tempdir("foobar_config");

    add_portage_repository( "$dir/test",
        "sabayon-community|git|https://github.com/Sabayon/community.git" );
    add_portage_repository( $dir,
        "sabayon|https://github.com/Sabayon/sabayon-distro.git" );
    add_portage_repository( $dir,
        "sabayon-gentoo-fake|svn://foobar.svn.com/Sabayon/for-gentoo" );
    ok( -e "${dir}/test/sabayon-community.conf",
        "add_portage_repository() correctly created : ${dir}/sabayon-community.conf"
    );
    ok( -e "${dir}/sabayon.conf",
        "add_portage_repository() correctly created : ${dir}/sabayon.conf" );
    ok( -e "${dir}/sabayon-gentoo-fake.conf",
        "add_portage_repository() correctly created : ${dir}/sabayon-gentoo-fake.conf"
    );

    open FILE, "<${dir}/sabayon.conf";
    my @FILE = <FILE>;
    chomp(@FILE);
    close FILE;
    is_deeply(
        \@FILE,
        [   "[sabayon]",
            "location = /usr/local/overlay/sabayon",
            "sync-type = git",
            "sync-uri = https://github.com/Sabayon/sabayon-distro.git",
            "auto-sync = yes"
        ],
        "Check if ${dir}/sabayon.conf is as should be generated."
    );

    open FILE, "<${dir}/sabayon-gentoo-fake.conf";
    @FILE = <FILE>;
    chomp(@FILE);
    close FILE;
    is_deeply(
        \@FILE,
        [   "[sabayon-gentoo-fake]",
            "location = /usr/local/overlay/sabayon-gentoo-fake",
            "sync-type = svn",
            "sync-uri = svn://foobar.svn.com/Sabayon/for-gentoo",
            "auto-sync = yes"
        ],
        "Check if ${dir}/sabayon-gentoo-fake.conf is as should be generated."
    );

    open FILE, "<${dir}/test/sabayon-community.conf";
    @FILE = <FILE>;
    chomp(@FILE);
    close FILE;
    is_deeply(
        \@FILE,
        [   "[sabayon-community]",
            "location = /usr/local/overlay/sabayon-community",
            "sync-type = git",
            "sync-uri = https://github.com/Sabayon/community.git",
            "auto-sync = yes"
        ],
        "Check if ${dir}/test/sabayon-community.conf is as should be generated."
    );

};

subtest "strip_version" => sub {
    my @list =
        qw(sys-fs/foobarfs-1.9.2 sys-fs/foobarfs-1.0.1 sys-fs/foobarfs-1.9_b2 sys-fs/foobarfs-1.9.2-r1 sys-fs/foobarfs-0.5.0_beta2-r1);
    for (@list) {
        strip_version();
        is( $_, "sys-fs/foobarfs", 'Strip version from packages' );
    }
};

subtest "return_strip_version" => sub {

    my @list =
        qw(sys-fs/foobarfs-1.9.2 sys-fs/foobarfs-1.0.1 sys-fs/foobarfs-1.9_b2 sys-fs/foobarfs-1.9.2-r1 sys-fs/foobarfs-0.5.0_beta2-r1);
    for my $package (@list) {
        my $res = return_strip_version($package);
        is( $res, "sys-fs/foobarfs", 'Strip version from packages' );
    }

};

subtest "detect_useflags" => sub {

    my @list =
        ( "sys-fs/foobarfs-1.9.2[X]", "sys-fs/foobarfs-1.0.1[-X,bar]" );

    my $useflags = detect_useflags(@list);

    is_deeply( $useflags->[0], [qw(X)],
        'detect_useflags on "sys-fs/foobarfs-1.9.2" is ok' );
    is_deeply( $useflags->[1], [qw(-X bar)],
        'detect_useflags on "sys-fs/foobarfs-1.0.1" is ok' );

};

done_testing;
