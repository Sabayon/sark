#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;
use Sark::State;
use YAML::Tiny;

subtest "validation" => sub {
    my $state = Sark::State->new('/dev/null');

    my $good_document = YAML::Tiny::Load(<<END);
disabled_repositories:
  - community
END

    lives_ok(
        sub { $state->validate($good_document) },
        'good document validates against state schema'
    );
};

subtest "default merging" => sub {
    my $good_document = {};

    my $full_state = Sark::State::_add_missing_defaults($good_document);

    # Check a variety of settings
    ok( defined( $full_state->{disabled_repositories} ),
        'disabled_repositories' );
    is( scalar @{ $full_state->{disabled_repositories} },
        0, 'disabled_repositories is empty' );

    # Check the merged document passes the schema validation
    my $state = Sark::State->new('/dev/null');
    lives_ok(
        sub { $state->validate($good_document) },
        'merged document validates against config schema'
    );
};

subtest "full parse from string" => sub {
    my $state = Sark::State->new('/dev/null');

    my $good_document = <<END;
disabled_repositories:
  - community
END

    $state->parse_config($good_document);

    is( scalar @{ $state->{data}->{disabled_repositories} },
        1, 'repository definitions' );
    is( $state->{data}->{disabled_repositories}[0],
        'community', 'community repository is disabled' );
};

done_testing;

