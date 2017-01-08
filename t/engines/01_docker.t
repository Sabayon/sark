#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Build;

my $api;
my $checkv;
eval {
    $api    = Sark::API::Interface::Docker->new();
    $checkv = $api->version()->{Version};
};

if ( !$api or $@ or !$checkv ) {
    diag("SKIPPED");
    plan skip_all =>
        'No Docker daemon running on machine, or cannot connect to it from the current user';
}

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
        "engine.Docker.build.start" => sub {
            isa_ok( $_[0], "Sark" );
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark::Build" );
            ok( $_[3] eq "start", "Sark::Build start()" );

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
    $build->start("start");
    $build->publish("publish");
    $build->post_clean("post_clean");
};

done_testing;
