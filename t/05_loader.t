#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark::Loader;

subtest "namespace search" => sub {

    my @modules = Sark::Loader->search('Sark::Plugin');

    is( $modules[0], 'Sark::Plugin::Test',
        'Searching Sark::Plugin should find Test' );

};

done_testing;

