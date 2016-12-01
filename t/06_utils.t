#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Sark;
use Sark::Utils qw(bool uniq);

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

done_testing;

