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
    $checkv = $api->version()->{Version};
};

if ( !$api or $@ or !$checkv ) {
    diag("SKIPPED");
    plan skip_all =>
        'No Docker daemon running on machine, or cannot connect to it from the current user';
}

subtest 'Sark::API::Interface::Docker internals' => sub {

    # Testing the possibility to decode json also with other sites.
    $api->address('https://jsonplaceholder.typicode.com');

    my $d_json = $api->_parse("/posts/1");
    ok( exists $d_json->{id},
        "Sark::API::Interface::Docker json structure exists" );
    is( $d_json->{id}, "1", "Sark::API::Interface::Docker _parse()" );

    my $res = $api->ua->post( $api->_uri('/posts') );
    $d_json = $api->_parse_request($res);
    ok( exists $d_json->{id},
        "Sark::API::Interface::Docker json structure exists" );
    is( $d_json->{id}, "101",
        "Sark::API::Interface::Docker _parse_request()" );

    $api->address('http:/var/run/docker.sock/');

};

subtest 'Sark::API::Interface::Docker version and info test' => sub {

    ok($api);

    my $version = $api->version;

    ok( $version->{GoVersion} );
    ok( $version->{Version} );

    diag( "Docker version detected: " . $version->{Version} );

    my $info = $api->info;
    ok( exists $info->{Containers}, "Check if image has 'Containers'" );
    ok( exists $info->{Images},     "Check if image has 'Images'" );

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
    my $pull    = $api->pull($testimg);
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
    $api->remove_image($testimg);
    $images = $api->images( filter => $testimg );
    my @imgs;
    foreach my $img ( @{$images} ) {
        my @tags = @{ $img->{RepoTags} };
        push( @imgs, @tags );

    }

    ok( !grep( /$testimg/, @imgs ),
        "$testimg docker image was successfully removed" );

};

done_testing();
