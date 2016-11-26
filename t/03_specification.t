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

    my $no_repo_description = YAML::Load(<<END);
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
    my $spec = Sark::Specification->new;

    my $sparse_spec = {
        type     => '//rec',
        optional => { foo => '//str', }
    };

    my $dense_spec = $spec->_make_dense_spec($sparse_spec);

    ok( defined( $dense_spec->{required}->{foo} ) );
    ok( !defined( $dense_spec->{optional} ) );

};

done_testing;
