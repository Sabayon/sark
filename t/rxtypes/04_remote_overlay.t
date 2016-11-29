#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;

use Data::Rx;
use Sark::RxType::RemoteOverlay;

subtest "remote_overlay" => sub {

    my $rx = Data::Rx->new(
        {   prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::RemoteOverlay
                    )
            ],
        }
    );

    my $success = { type => 'tag:sabayon.org:sark/remote_overlay', };

    my $schema = $rx->make_schema($success);

    my @expect_ok = (
        'test|git|https://github.com/foo/bar',
        'test|svn|svn+ssh://foobar.com/foo',
    );

    for my $test (@expect_ok) {
        lives_ok { $schema->assert_valid($test) } $test;
    }

    my @expect_bad = ( '', 'test', 'test|random', 'test|random|blah', );

    for my $test (@expect_bad) {
        throws_ok { $schema->assert_valid($test) } 'Data::Rx::FailureSet',
            $test;
    }
};

done_testing;

