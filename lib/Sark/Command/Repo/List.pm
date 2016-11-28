package Sark::Command::Repo::List;
use base qw( Sark::Command::Repo );

use warnings;
use strict;

use Sark;
use Sark::Repo;

sub usage_text {
    "sark repo list";
}

sub run {
    my ($opts, @args) = @_;
    my $sark = Sark->new;
    
    my @repos = Sark::Repo::list();
    
    return {
        lines => \@repos,
    };
}

1;

