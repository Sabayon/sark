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
    my $dweet = $thing->latest();
    ok( exists $dweet->{content}->{this}->{is}->{real},
        "Dweet successfully created and received."
    );
    is( $dweet->{content}->{this}->{is}->{real}, "yes!",
        "Dweet successfully created and received."
    );
    $thing->dweet( this => { is => { unreal => "no!" } } );
    my @test = $thing->dweets;
    ok( exists $test[1]->{content}->{this}->{is}->{real},
        "Dweet successfully created and received."
    );
    ok( exists $test[0]->{content}->{this}->{is}->{unreal},
        "Dweet successfully created and received."
    );
    is( $test[1]->{content}->{this}->{is}->{real}, "yes!",
        "Dweet successfully created and received."
    );
    is( $test[0]->{content}->{this}->{is}->{unreal}, "no!",
        "Dweet successfully created and received."
    );
};

done_testing();
