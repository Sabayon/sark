
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
        "engine.docker.build.prepare" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.pre_clean" => sub {
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

    Sark->instance->on(
        "engine.docker.build.publish" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
        }
    );

    Sark->instance->on(
        "engine.docker.build.post_clean" => sub {
            isa_ok( $_[1], "Sark::Engine::Docker" );
            isa_ok( $_[2], "Sark" );
            isa_ok( $_[3], "Sark::Build" );
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
