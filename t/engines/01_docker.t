#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Build;

subtest "engines" => sub {

    Sark->instance->load_engine("Docker");

    Sark->instance->on(
        "engine.Docker.build.prepare" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "prepare", "Sark::Build prepare()" );
        }
    );

    Sark->instance->on(
        "engine.Docker.build.pre_clean" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "pre_clean", "Sark::Build pre_clean()" );

        }
    );

    Sark->instance->on(
        "engine.Docker.build.compile" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "compile", "Sark::Build compile()" );

        }
    );

    Sark->instance->on(
        "engine.Docker.build.publish" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "publish", "Sark::Build publish()" );

        }
    );

    Sark->instance->on(
        "engine.Docker.build.post_clean" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "post_clean", "Sark::Build post_clean()" );

        }
    );

    my $build = Sark::Build->new();

    $build->prepare("prepare");
    $build->pre_clean("pre_clean");
    $build->compile("compile");
    $build->publish("publish");
    $build->post_clean("post_clean");
};

done_testing;
