#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;

use Data::Rx;
use Sark::RxType::Atom;

subtest "atom" => sub {

    my $rx = Data::Rx->new(
        {   prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::Atom
                    )
            ],
        }
    );

    my $success = { type => 'tag:sabayon.org:sark/atom', };

    my $schema = $rx->make_schema($success);

    my @expect_ok = (
        'app-misc/foo',
        '=app-misc/foo-1',
        '=app-misc/foo-1.2_alpha1-r1',
        '>=app-misc/foo-1',
        'foobar',
        'foobar:0',
        'foobar[-use]',
        'foobar::repo',
        'foobar#tag',
        '>=app-misc/foobar-1.2_alpha1-r1:0[-use]#tag::repo',
    );

    for my $test (@expect_ok) {
        lives_ok { $schema->assert_valid($test) } $test;
    }

    my @expect_bad = (

        # Empty atoms are not valid
        '',

        # Incomplete atoms
        'foo/',
        'foo/bar[-use',

        # Duplicate components
        'foo/foo/bar',
        'foo/bar:0:0',
        'foo:bar:bar',
        'foo/bar#tag#tag',
        'foo/bar::repo::repo',
    );

    for my $test (@expect_bad) {
        throws_ok { $schema->assert_valid($test) } 'Data::Rx::FailureSet',
            $test;
    }
};

done_testing;
