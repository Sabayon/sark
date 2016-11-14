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
    Sark->DESTROY();
};

subtest "engines" => sub {

    Sark->instance( engine => "Docker" );

    Sark->instance->on(
        "engine.docker.build.prepare" => sub {
            is( $_[1]->isa("Sark::Engine::Docker"),
                1, "Docker engine prepare event triggered" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.configure" => sub {
            is( $_[1]->isa("Sark::Engine::Docker"),
                1, "Docker engine configure event triggered" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.compile" => sub {
            is( $_[1]->isa("Sark::Engine::Docker"),
                1, "Docker engine compile event triggered" );
        }
    );

    my $build = Sark::Build->new();

    $build->prepare("prepare");
    $build->configure("configure");
    $build->compile("compile");
    Sark->DESTROY();

};

done_testing;
