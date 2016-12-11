#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Test::TempDir::Tiny;
use Sark;
use Sark::Repo;

in_tempdir "listing repositories" => sub {
    mkdir("foo");
    mkdir("bar");

    my $sark = Sark->new;

    # Force Sark to use current test directory for repository locations
    $sark->{config}->{data}->{repositories}->{definitions} = '.';

    is_deeply(
        [ Sark::Repo->list ],
        [ "bar", "foo" ],
        'list available repos'
    );
};

in_tempdir "bulk enabling repos" => sub {
    mkdir('foo');
    mkdir('bar');
    mkdir('baz');
    mkdir('qux');

    my $sark = Sark->new;

    # Force Sark to use current test directory for repository locations
    $sark->{config}->{data}->{repositories}->{definitions} = '.';

    # Manually disable some test repositories
    $sark->{state}->{data}->{disabled_repositories} = [ 'foo', 'bar', 'baz' ];

    is_deeply(
        [ Sark::Repo->disabled ],
        [ 'bar', 'baz', 'foo' ],
        'Ensure initial repos are disabled'
    );
    is_deeply( [ Sark::Repo->enabled ],
        ['qux'], 'Ensure initial repos are enabled' );

    # Manually enable one repository
    Sark::Repo->enable_repos( ["foo"], 0 );

    # Ensure correct repos are still enabled/disabled
    is_deeply(
        [ Sark::Repo->disabled ],
        [ 'bar', 'baz' ],
        'Still disabled after single test'
    );
    is_deeply(
        [ Sark::Repo->enabled ],
        [ 'foo', 'qux' ],
        'Still enabled after single test'
    );

    # Manually enable multiple repositories
    Sark::Repo->enable_repos( [ 'bar', 'baz' ], 0 );

    # Ensure correct repos are still enabled/disabled
    is_deeply( [ Sark::Repo->disabled ],
        [], 'Still disabled after multiple test' );
    is_deeply(
        [ Sark::Repo->enabled ],
        [ 'bar', 'baz', 'foo', 'qux' ],
        'Still enabled after multiple test'
    );
};

in_tempdir "bulk disabling repos" => sub {
    mkdir('foo');
    mkdir('bar');
    mkdir('baz');
    mkdir('qux');

    my $sark = Sark->new;

    # Force Sark to use current test directory for repository locations
    $sark->{config}->{data}->{repositories}->{definitions} = '.';

    # Manually disable some test repositories
    $sark->{state}->{data}->{disabled_repositories} = ['foo'];

    is_deeply( [ Sark::Repo->disabled ],
        ['foo'], 'Ensure initial repos are disabled' );
    is_deeply(
        [ Sark::Repo->enabled ],
        [ 'bar', 'baz', 'qux' ],
        'Ensure initial repos are enabled'
    );

    # Manually enable one repository
    Sark::Repo->disable_repos( ["bar"], 0 );

    # Ensure correct repos are still enabled/disabled
    is_deeply(
        [ Sark::Repo->disabled ],
        [ 'bar', 'foo' ],
        'Still disabled after single test'
    );
    is_deeply(
        [ Sark::Repo->enabled ],
        [ 'baz', 'qux' ],
        'Still enabled after single test'
    );

    # Manually enable multiple repositories
    Sark::Repo->disable_repos( [ 'baz', 'qux' ], 0 );

    # Ensure correct repos are still enabled/disabled
    is_deeply(
        [ Sark::Repo->disabled ],
        [ 'bar', 'baz', 'foo', 'qux' ],
        'Still disabled after multiple test'
    );
    is_deeply( [ Sark::Repo->enabled ],
        [], 'Still enabled after multiple test' );
};

done_testing;

