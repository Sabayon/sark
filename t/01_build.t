#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Build;

# Testing compile and test events
subtest "events" => sub {
    Sark->instance->on( "build.prepare" =>
            sub { is( $_[2], "prepare", "build.prepare event received" ) }
    );
    Sark->instance->on( "build.pre_clean" =>
            sub { is( $_[2], "pre_clean", "build.pre_clean event received" ) }
    );
    Sark->instance->on( "build.compile" =>
            sub { is( $_[2], "compile", "build.compile event received" ) } );
    
    Sark->instance->on( "build.publish" =>
            sub { is( $_[2], "publish", "build.publish event received" ) }
    );
    Sark->instance->on( "build.post_clean" =>
            sub { is( $_[2], "post_clean", "build.post_clean event received" ) }
    );
    
    my $build = Sark::Build->new;
    $build->prepare("prepare");
    $build->pre_clean("pre_clean");
    $build->compile("compile");
    $build->publish("publish");
    $build->post_clean("post_clean");
};

done_testing;
