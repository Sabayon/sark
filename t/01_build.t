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
    Sark->instance->on( "build.compile" =>
            sub { is( $_[2], "compile", "build.compile event received" ) } );
    Sark->instance->on(
        "build.configure" =>
            sub { is( $_[2], "configure", "build.configure event received" ) }
    );
    Sark->instance->on( "build.prepare" =>
            sub { is( $_[2], "prepare", "build.configure event received" ) }
    );
    my $build = Sark::Build->new;

    $build->prepare("prepare");
    $build->configure("configure");
    $build->compile("compile");
};

subtest "engines" => sub {

    Sark->instance->load_engine("Docker");

    Sark->instance->on(
        "engine.docker.build.prepare" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.configure" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.compile" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
        }
    );

    my $build = Sark::Build->new();

    $build->prepare("prepare");
    $build->configure("configure");
    $build->compile("compile");
};

done_testing;
