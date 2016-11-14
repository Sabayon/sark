#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers qw(initialize);
use Test::More;
use Sark;

Sark->new;

# Testing plugin loading
subtest "loading" => sub {
    Sark->instance->on( "plugin.test.success" =>
            sub { is( $_[1], "test", "plugin.test.success event received" ) }
    );
    Sark->instance->plugin(qw( Test ));
    Sark->instance->init();

};

done_testing;
