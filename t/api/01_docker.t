#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Test::More;
use Sark::API::Interface::Docker;

subtest 'Test Sark::API::Interface::Docker' => sub {

    my $api;
    my $checkv;
    eval {
        $api    = Sark::API::Interface::Docker->new();
        $checkv = $api->version();
    };
    if ( !$api or $@ or !$checkv ) {
        diag("SKIPPED");
        plan skip_all =>
            'No Docker connection on machine, or cannot connect to it from the current user';
    }
    else {

        ok($api);

        my $version = $api->version;

        ok( $version->{GoVersion} );
        ok( $version->{Version} );

        diag( "Docker version: " . $version->{Version} );
        diag( "Go version: " . $version->{GoVersion} );

        my $info = $api->info;
        ok( exists $info->{Containers} );
        ok( exists $info->{Images} );
    }
};

done_testing();
