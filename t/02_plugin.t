#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;

# Testing plugin loading
subtest "loading without env" => sub {

# Create a Sark instance with the Test plugin (Sark::Plugin::Test)
# listen also on "plugin.test.success", and complete the test checking if receives the arguments.
    Sark->instance( plugin => [qw(Test1)] )->on(
        "plugin.test1.success" =>
            sub { is( $_[1], "test", "plugin.test1.success event received" ) }
    );
    is( Sark->instance->loaded("Test1"),
        1, "There is one plugin, Test1, loaded" );

    # Emit plugin.test
    Sark->instance->emit("plugin.test1");

};

done_testing;
