#!/usr/bin/env perl
use lib './t/lib';
use warnings FATAL => 'all';
use strict;
use Helpers;
use Test::More;
use Test::Exception;
use Sark;
use Sark::Config;
use YAML::Tiny;

subtest "validation" => sub {
    my $config = Sark::Config->new;

    my $good_document = YAML::Tiny::Load(<<END);
repositories:
  definitions: "/tmp/sark/repositories"
END

    lives_ok(
        sub { $config->validate($good_document) },
        'good document validates against config schema'
    );
};

subtest "default merging" => sub {
    my $good_document = YAML::Tiny::Load(<<END);
repositories:
  definitions: "/tmp/sark/repositories"
END

    my $full_config = Sark::Config::_add_missing_defaults($good_document);

    # Check a variety of settings
    ok( defined( $full_config->{repositories}->{definitions} ),
        'repositories: definitions' );
    ok( defined( $full_config->{repositories}->{url} ), 'repositories: url' );

    # Check the merged document passes the schema validation
    my $config = Sark::Config->new;
    lives_ok(
        sub { $config->validate($good_document) },
        'merged document validates against config schema'
    );
};

subtest "environment overrides" => sub {
    my $config = {
        repositories => {
            definitions => "/one/sark/repositories",
            url =>
                "https://github.com/Sabayon/community-repositories-fork.git"
        },
    };

    Sark::Config::_override_single( $config->{repositories},
        'definitions', '/two/sark/repositories' );
    is( $config->{repositories}->{definitions},
        '/two/sark/repositories', 'definitions override' );

    Sark::Config::_override_single( $config->{repositories}, 'url', undef );
    is( $config->{repositories}->{url},
        "https://github.com/Sabayon/community-repositories-fork.git" );

};

subtest "full parse from string" => sub {
    my $config = Sark::Config->new;

    my $good_document = <<END;
repositories:
  definitions: "/tmp/sark/repositories"
END

    $config->parse_config($good_document);

    is( $config->{data}->{repositories}->{definitions},
        '/tmp/sark/repositories', 'repository definitions' );
    is( $config->{data}->{repositories}->{url},
        'https://github.com/Sabayon/community-repositories.git',
        'repository url'
    );
};

done_testing;

