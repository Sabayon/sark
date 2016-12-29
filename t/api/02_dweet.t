#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Test::More;
use Sark::API::Interface::Dweet;
use Test::TempDir::Tiny;
use Data::UUID;

subtest 'Sark::API::Interface::Dweet internals' => sub {
    my $uuid = Data::UUID->new->create_str;
    my $thing = Sark::API::Interface::Dweet->new( thing => $uuid );
    $thing->dweet( this => { is => { real => "yes!" } } );
    my $dweet      = $thing->latest();
    my $url        = $thing->follow_link();
    my $dweets_url = $thing->dweets_link();
    $thing->dweet( this => { is => { unreal => "no!" } } );
    my @test = $thing->dweets;

    is( $url,
        $thing->address . "/follow/" . $thing->thing,
        "Follow link is correct!"
    );
    is( $dweets_url,
        $thing->address . "/get/dweets/for/" . $thing->thing,
        "Dweets link is correct!"
    );
    diag(
        "You can check the test status on $url or all dweets at $dweets_url");
    ok( exists $dweet->{content}->{this}->{is}->{real},
        "Latest dweet content->this->is->real exists."
    );
    is( $dweet->{content}->{this}->{is}->{real},
        "yes!", "Latest dweet content content->this->is->real is 'yes!'" );
    ok( exists $test[1]->{content}->{this}->{is}->{real},
        "content->this->is->real exists as the last one dweet in the timeline."
    );
    ok( exists $test[0]->{content}->{this}->{is}->{unreal},
        "content->this->is->unreal exists as the first one dweet in the timeline (more recent). "
    );
    is( $test[1]->{content}->{this}->{is}->{real}, "yes!",
        "content->this->is->real with content is 'yes!' as the last one dweet in the timeline."
    );
    is( $test[0]->{content}->{this}->{is}->{unreal}, "no!",
        "content->this->is->unreal with content is 'no!' as the last one dweet in the timeline."
    );
};

done_testing();
