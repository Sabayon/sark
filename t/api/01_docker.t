#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Test::More;
use Sark::API::Interface::Docker;

my $api;
my $checkv;
eval {
    $api    = Sark::API::Interface::Docker->new();
    $checkv = $api->version();
};

if ( !$api or $@ or !$checkv ) {
    diag("SKIPPED");
    plan skip_all =>
        'No Docker daemon running on machine, or cannot connect to it from the current user';
}

subtest 'Sark::API::Interface::Docker version and info test' => sub {

    ok($api);

    my $version = $api->version;

    ok( $version->{GoVersion} );
    ok( $version->{Version} );

    diag( "Docker version: " . $version->{Version} );
    diag( "Go version: " . $version->{GoVersion} );

    my $info = $api->info;
    ok( exists $info->{Containers}, "Check if image has 'Containers'" );
    ok( exists $info->{Images},     "Check if image has 'Images'" );

};

subtest 'Sark::API::Interface::Docker image tests' => sub {

    my $testimg = "busybox:latest";
    my $pull    = $api->pull($testimg);
    my $images  = $api->images( filter => $testimg );
    foreach my $img ( @{$images} ) {
        my @tags = @{ $img->{RepoTags} };
        like( "@tags", qr/$testimg/,
            "$testimg docker image is available from the image list" );
    }

    ok( exists $pull->{status} );
    like(
        $pull->{status},
        qr/Pulling from .*/,
        "Pulled $testimg docker image"
    );

    my $inspect = $api->inspect($testimg);
    ok( exists $inspect->{Id},       "Check if image has Id" );
    ok( exists $inspect->{RepoTags}, "Check if image has RepoTags" );

};

subtest 'Sark::API::Interface::Docker search tests' => sub {

    ## Note: this test is highly correlated with busybox image,
    ## thus it may break, if upstream changes configurations.

    my $testimg = "busybox";
    my $search = $api->search( term => $testimg, limit => 1 );
    is( $search->[0]->{name}, $testimg, "Found $testimg image" );
    is( $search->[0]->{is_official},  1, "Found $testimg official image" );
    is( $search->[0]->{is_automated}, 0, "Found $testimg, not automated" );

};

subtest 'Sark::API::Interface::Docker container tests' => sub {

    ## Note: this test is highly correlated with busybox image,
    ## thus it may break, if upstream changes configurations.
    use HTTP::Status qw(:constants :is status_message);

    my $testimg = "busybox:latest";
    $api->stop("sark-test");
    $api->remove_container("sark-test");

    my $id = $api->create(
        Image       => $testimg,
        Cmd         => ['/bin/sh'],
        AttachStdin => \1,
        OpenStdin   => \1,
        Name        => 'sark-test',
    );

    $api->start($id);

    # Let's check if the container we started is there.
    # Then let's check if we stopped and removed it successfully
    foreach my $running ( @{ $api->containers( all => 1 ) } ) {
        if ( $running->{Names}
            and grep( /$testimg/, join( " ", $running->{Image} ) ) )
        {

            is( $running->{Id}, $id, "Found running container $id" );
            $api->stop( $running->{Id} );
            my $curr_container_status =
                $api->inspect_container( $running->{Id} );
            is( $curr_container_status->{State}->{Status},
                "exited", "Successfully stopped the container" );
            $api->remove_container( $running->{Id} );
            $curr_container_status =
                $api->inspect_container( $running->{Id} );
            is( $curr_container_status->code == HTTP_NOT_FOUND,
                1, "Container not anymore there" );
        }
    }

};

done_testing();
