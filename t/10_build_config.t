#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Sark::Build::Config;
use Test::More;

subtest "add()" => sub {

    my $config = Sark::Build::Config->new;

    $config->add( "foo",  "bar" );
    $config->add( "foo1", "bar1" );

    is( $config->get("foo"), "bar",
        "add()/get() currectly add and return a key/value pair" );

    is( $config->get("foo1"),
        "bar1", "add()/get() currectly add and return a key/value pair" );

};

subtest "remove()" => sub {

    my $config = Sark::Build::Config->new;

    $config->add( "foo", "bar" );
    $config->remove("foo");

    my $foo = $config->get("foo");
    is( $foo, undef, "remove() correctly removed the key" );

};

subtest "array()" => sub {

    my $config = Sark::Build::Config->new;

    $config->add( "foo", "bar" );
    $config->add( "app", "baz" );

    my @array = $config->array;
    ok( "@array" =~ /foo\=bar/, "array contains foo=bar" );
    ok( "@array" =~ /app\=baz/, "array contains foo=bar" );

    my $foo = $config->get("foo1");
    is( $foo, undef, "foo1 shouldn't be present!" );
};

done_testing;
