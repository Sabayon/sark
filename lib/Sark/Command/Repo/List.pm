package Sark::Command::Repo::List;
use base qw( Sark::Command::Repo );

use warnings;
use strict;

use CLI::Framework::Exceptions qw( :all );
use Log::Log4perl;

use Sark;
use Sark::Repo;

sub usage_text {
    "sark repo list [--enabled|--disabled]";
}

sub option_spec {
    (   [   'filter' => hidden => {
                one_of => [
                    [   'enabled|e' =>
                            'limit output to only enabled repositories',
                        { default => 0, }
                    ],
                    [   'disabled|d' =>
                            'limit output to only disabled repositories',
                        { default => 0, }
                    ],
                ]
            }
        ],
    );
}

sub run {
    my ( $self, $opts, @args ) = @_;
    my $sark   = Sark->new;
    my $logger = Log::Log4perl->get_logger('Sark::Command::Repo::List');

    my @repos;

    if ( $opts->enabled ) {
        @repos = Sark::Repo->enabled;
    }
    elsif ( $opts->{disabled} ) {
        @repos = Sark::Repo->disabled;
    }
    else {
        @repos = Sark::Repo->list;
    }

    return { lines => \@repos, };
}

1;

