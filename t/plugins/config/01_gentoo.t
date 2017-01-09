#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;
use Sark::Build;

subtest "load Config::Gentoo and parse config" => sub {
    Sark->instance()->load_plugin("Config::Gentoo");
    my $build = Sark::Build->new;
    $build->enable_plugin("Config::Gentoo");
    $build->_config->{emerge}->{split_install} = 1;
    $build->prepare();
    is( $build->config->get("EMERGE_SPLIT_INSTALL"),
        1, "EMERGE_SPLIT_INSTALL is set to 1" );
};

done_testing;
