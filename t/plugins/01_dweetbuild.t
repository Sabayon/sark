#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Test::More;
use Sark::Build;
use Sark;
use Sark::API::Interface::Dweet;
use Data::Dumper;

subtest 'Sark::Plugin::DweetBuild load' => sub {

    # Load the plugin.
    Sark->instance->load_plugin("DweetBuild");
    ok( Sark->instance->loaded("DweetBuild"), "Plugin loaded" );

    # Enable the plugin for the build.
    my $build = Sark::Build->new();
    $build->enable_plugin("DweetBuild");
    $build->prepare("test");

    # Check if message is there.
    my $thing = Sark::API::Interface::Dweet->new( thing => $build->id );
    my $dweet = $thing->latest();
    ok( $dweet->{content}->{status} eq "prepare",
        "Dweet successfully created and received."
    );

};

done_testing();
