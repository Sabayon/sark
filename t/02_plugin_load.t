#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;

subtest "loading with env" => sub {

# Create a Sark instance with the Test plugin (Sark::Plugin::Test)
# listen also on "plugin.test.success", and complete the test checking if receives the arguments.

    Sark->instance()->load_plugin("Test");
    Sark->instance()->load_engine("Docker");

    Sark->instance()
        ->on( "plugin.test.success" =>
            sub { is( $_[1], "test", "plugin.test.success event received" ) }
        );

    is( Sark->instance->loaded("Test"),
        1, "There is one plugin, Test, loaded" );
    is( Sark->instance->loaded("Docker"),
        1, "There is one engine, Docker, loaded" );

    # Emit plugin.test
    Sark->instance->emit("plugin.test");

};

done_testing;
1;
