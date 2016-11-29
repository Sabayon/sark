#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark::Loader;

subtest "namespace search" => sub {

    my @modules = Sark::Loader->search('Sark::Plugin');

    is( grep( /Sark::Plugin::Test/, @modules ),
        2, 'Searching Sark::Plugin should find Test and Test1' );

};

done_testing;
