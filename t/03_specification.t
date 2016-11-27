#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;
use Sark::Specification;
use YAML::Tiny;

subtest "validation" => sub {
    my $spec = Sark::Specification->new;

    my $good_document = YAML::Tiny::Load(<<END);
repository:
  description: Test Repo
build:
  target:
    - app-misc/foo
END

    my $no_repo_description = YAML::Tiny::Load(<<END);
build:
  target:
    - app-misc/foo
END

    lives_ok { $spec->validate($good_document) }
    'good document validates against sparse spec';
    throws_ok { $spec->validate($no_repo_description) }
    'Data::Rx::FailureSet', 'no repository description throws error';

    throws_ok { $spec->validate( $good_document, 0 ) } 'Data::Rx::FailureSet',
        'good document (sparse) fails against dense spec';
};

subtest "sparse-dense spec conversion" => sub {
    my $sparse_spec = {
        type     => '//rec',
        optional => { foo => '//str', }
    };

    my $dense_spec = Sark::Specification::_make_dense_spec($sparse_spec);

    ok( defined( $dense_spec->{required}->{foo} ) );
    ok( !defined( $dense_spec->{optional} ) );

};

subtest "default merging" => sub {
    my $sparse_spec = {
        repository => { description => "Test repo", },
        build      => { target      => [ 'app-misc/foobar', ] }
    };

    my $dense_spec = Sark::Specification::_add_missing_defaults($sparse_spec);

    # Check a variety of settings
    ok( defined( $dense_spec->{repository}->{maintenance}->{clean_cache} ),
        'repository: maintenance: clean_cache' );
    ok( defined( $dense_spec->{build}->{equo}->{repositories} ),
        'build: equo: repositories' );
    ok( defined( $dense_spec->{build}->{equo}->{package} ),
        'build: equo: package: install' );
    ok( defined( $dense_spec->{build}->{emerge}->{default_args} ),
        'build: emerge: default_args' );

    # Check the merged document passes the dense spec validation
    my $spec = Sark::Specification->new;
    lives_ok { $spec->validate( $dense_spec, 0 ) }
    'merged document validates against dense spec';
};

subtest "environment overrides" => sub {
    my $spec = {
        repository => { description => "Test repo", },
        build      => { target      => [ 'app-misc/foobar', ] }
    };

    Sark::Specification::_override_single( $spec->{build}, 'target',
        ['app-misc/baz'] );
    is( $spec->{build}->{target}[0], 'app-misc/baz', 'target override' );

    Sark::Specification::_override_single( $spec->{repository},
        'description', undef );
    is( $spec->{repository}->{description}, "Test repo" );

};

done_testing;
