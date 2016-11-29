#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;

use Data::Rx;
use Sark::RxType::Overlay;

subtest "overlay" => sub {

    my $rx = Data::Rx->new(
        {   prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::Overlay
                    )
            ],
        }
    );

    my $success = { type => 'tag:sabayon.org:sark/overlay', };

    my $schema = $rx->make_schema($success);

    my @expect_ok = (

        # Picking a random selection of overlay names from zugaina
        # to stress some edge cases
        'Armageddon',
        'mrueg',
        'ohnobinki_overlay',
        'ROKO__',
        'sabayon-distro',
    );

    for my $test (@expect_ok) {
        lives_ok { $schema->assert_valid($test) } $test;
    }

    my @expect_bad = ( '', '.hidden', 'foo bar', 'baz|qux', );

    for my $test (@expect_bad) {
        throws_ok { $schema->assert_valid($test) } 'Data::Rx::FailureSet',
            $test;
    }
};

done_testing;

