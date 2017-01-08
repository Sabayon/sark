#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Utils
    qw(array_minus bool filewrite hash_getkey uniq camelize decamelize);
use Test::TempDir::Tiny;

subtest "filewrite" => sub {
    my $dir = tempdir("foobar");
    filewrite( ">", $dir . "/test", "whatever" );

    ok( -e $dir . "/test", "filewrite correctly created file" );
    open FILE, "<$dir/test";
    my $content = <FILE>;
    close FILE;
    is( $content, "whatever",
        "filewrite correctly created file with 'whatever' content" );

    filewrite( ">>", "$dir/test", "2" );
    open FILE, "<$dir/test";
    $content = <FILE>;
    close FILE;
    is( $content, "whatever2",
        "filewrite correctly appended file with '2' as content" );

    filewrite( ">", $dir . "/test", "done" );
    open FILE, "<$dir/test";
    $content = <FILE>;
    close FILE;
    is( $content, "done", "filewrite correctly replaced file content" );

};
subtest "uniq" => sub {
    is_deeply( [ uniq() ],          [],  'Empty list' );
    is_deeply( [ sort( uniq(1) ) ], [1], 'Single element' );
    is_deeply(
        [ sort( uniq( 1, 2, 3 ) ) ],
        [ 1, 2, 3 ],
        'Multiple elements, no duplicates'
    );
    is_deeply( [ sort( uniq( 1, 1 ) ) ],
        [1], 'Multiple elements, all duplicates' );
    is_deeply(
        [ sort( uniq( 1, 1, 2, 3 ) ) ],
        [ 1, 2, 3 ],
        'Multiple elements, consecutive duplicates'
    );
    is_deeply(
        [ sort( uniq( 1, 2, 1, 2, 1, 3 ) ) ],
        [ 1, 2, 3 ],
        'Multiple elements, discontiguous duplicates'
    );
    is_deeply(
        [ sort( uniq( 1, 'one', 2, 'one' ) ) ],
        [ 1, 2, 'one' ],
        'Mixed types'
    );
};

subtest "bool" => sub {
    is( bool(1),  1, 'Already true' );
    is( bool(0),  0, 'Already false' );
    is( bool(''), 0, 'Empty string' );

    my @true_values = (
        'y',    'Y',    'yes', 'Yes', 'YES', 'true',
        'True', 'TRUE', 'on',  'On',  'ON'
    );
    my @false_values = (
        'n',     'N',     'no',  'No',  'NO', 'false',
        'False', 'FALSE', 'off', 'Off', 'OFF'
    );
    my @unrecognised_values = ( 2, -1, 'abc', (), [], {} );

    for my $value (@true_values) {
        is( bool($value), 1, "bool($value) should be true" );
    }

    for my $value (@false_values) {
        is( bool($value), 0, "bool($value) should be false" );
    }

    for my $value (@unrecognised_values) {
        is( bool($value), 0, "bool($value) should be false" );
    }

};

subtest "array_minus" => sub {
    my @a = qw( a b c d );
    my @b = qw( c d e f );

    my @minus = array_minus( @a, @b );
    is( scalar(@minus), 2, "Array minus count" );
    is_deeply( \@minus, [qw( a b )], "Array minus" );

};

subtest "hash_getkey" => sub {
    my $a = {
        data => { foo => "bar" },
        baz  => { bar => "baz" },
        ba   => {
            bo   => { test_array => [ 1, 2, 3 ] },
            void => { empty      => "null" }
        }
    };

    my $baz   = hash_getkey( $a, "bar" );
    my $bar   = hash_getkey( $a, "foo" );
    my $array = hash_getkey( $a, "test_array" );
    my $null  = hash_getkey( $a, "empty" );

    ok( $baz eq "baz",   "baz found inside baz->bar" );
    ok( $bar eq "bar",   "bar found inside data->foo" );
    ok( $null eq "null", "null found inside ba->bo->void" );
    is_deeply( $array, [ 1, 2, 3 ], "found test_array" );

};

subtest "camelize/decamelize" => sub {

    # camelize
    is camelize('foo_bar_baz'), 'FooBarBaz', 'right camelized result';
    is camelize('FooBarBaz'),   'FooBarBaz', 'right camelized result';
    is camelize('foo_b_b'),     'FooBB',     'right camelized result';
    is camelize('foo-b_b'),     'Foo::BB',   'right camelized result';
    is camelize('FooBar'),      'FooBar',    'already camelized';
    is camelize('Foo::Bar'),    'Foo::Bar',  'already camelized';

    # decamelize
    is decamelize('FooBarBaz'),   'foo_bar_baz', 'right decamelized result';
    is decamelize('foo_bar_baz'), 'foo_bar_baz', 'right decamelized result';
    is decamelize('FooBB'),       'foo_b_b',     'right decamelized result';
    is decamelize('Foo::BB'),     'foo-b_b',     'right decamelized result';

};

done_testing;
