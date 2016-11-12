#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers qw(initialize);
use Test::More;
use Sark;
use Sark::Build;

initialize();

# Testing compile and test events
subtest "events" => sub {
    Sark->instance->on( "build.compile" =>
            sub { is( $_[2], "test", "build.complete event received" ) } );
    Sark->instance->on( "build.test" =>
            sub { is( $_[2], "test", "build.test event received" ) } );
    my $build = Sark::Build->new;

    $build->compile("test");
    $build->test("test");

};

done_testing;
