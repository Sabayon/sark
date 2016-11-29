#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;

# Testing plugin loading
subtest "loading" => sub {

# Create a Sark instance with the Test plugin (Sark::Plugin::Test)
# listen also on "plugin.test.success", and complete the test checking if receives the arguments.
    $ENV{SARK_BUILD_PLUGINS} = "Test";

    Sark->instance()
        ->on( "plugin.test.success" =>
            sub { is( $_[1], "test", "plugin.test.success event received" ) }
        );

    # Emit plugin.test
    Sark->instance->emit("plugin.test");
};

done_testing;
