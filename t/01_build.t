#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Build;
use Test::TempDir::Tiny;

# Testing compile and test events
subtest "events" => sub {
    use Data::UUID;
    Sark->instance->on( "build.prepare" =>
            sub { is( $_[2], "prepare", "build.prepare event received" ) } );
    Sark->instance->on(
        "build.pre_clean" =>
            sub { is( $_[2], "pre_clean", "build.pre_clean event received" ) }
    );
    Sark->instance->on( "build.compile" =>
            sub { is( $_[2], "compile", "build.compile event received" ) } );
    Sark->instance->on( "build.start" =>
            sub { is( $_[2], "start", "build.start event received" ) } );
    Sark->instance->on( "build.publish" =>
            sub { is( $_[2], "publish", "build.publish event received" ) } );
    Sark->instance->on(
        "build.post_clean" => sub {
            is( $_[2], "post_clean", "build.post_clean event received" );
        }
    );

    my $build = Sark::Build->new;
    $build->prepare("prepare");
    $build->pre_clean("pre_clean");
    $build->compile("compile");
    $build->start("start");
    $build->publish("publish");
    $build->post_clean("post_clean");

    #ok( $build->engines()->[0] eq "Docker",
    #    "Default build configuration has Docker engine as default" );
    ok( !$build->has_engine("Docker"),
        "Default build configuration doesn't have Docker engine loaded" );
    ok( !$build->has_plugin("Docker"),
        "Default build configuration has no 'Docker' plugin" );

    my $id  = $build->id;
    my $id2 = Sark::Build->new->id;
    my $ug  = Data::UUID->new;
    ok( $ug->compare( $id, $id2 ) != 0,
        "Different Builds objects generates differents UUIDs" );

};

done_testing;
