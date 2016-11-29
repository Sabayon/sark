#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;

use Data::Rx;
use Sark::RxType::DockerImage;

subtest "docker_image" => sub {

    my $rx = Data::Rx->new(
        {   prefix       => { sark => 'tag:sabayon.org:sark/', },
            type_plugins => [
                qw(
                    Sark::RxType::DockerImage
                    )
            ],
        }
    );

    my $success = { type => 'tag:sabayon.org:sark/docker_image', };

    my $schema = $rx->make_schema($success);

    my @expect_ok = (
        'sabayon/builder-amd64', 'sabayon/builder-amd64:tagged',
        'sabayon/eit-amd64',
    );

    for my $test (@expect_ok) {
        lives_ok { $schema->assert_valid($test) } $test;
    }

    my @expect_bad = (
        'sabayon/',       'builder-amd64',
        '/builder-amd64', 'sabayon/builder-amd64:foo:foo',
    );

    for my $test (@expect_bad) {
        throws_ok { $schema->assert_valid($test) } 'Data::Rx::FailureSet',
            $test;
    }
};

done_testing;

