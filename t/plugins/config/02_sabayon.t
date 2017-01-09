#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;
use Sark::Build;

subtest "load Config::Sabayon and parse config" => sub {
    Sark->instance()->load_plugin("Config::Sabayon");
    my $build = Sark::Build->new;
    $build->enable_plugin("Config::Sabayon");
    $build->_config->{equo}->{dependency_install}->{enable} = "true";
    $build->prepare();
    is( $build->config->get("USE_EQUO"), 1, "USE_EQUO is set to 1" );
};

done_testing;
