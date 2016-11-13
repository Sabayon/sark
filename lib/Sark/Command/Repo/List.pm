package Sark::Command::Repo::List;
use base qw( Sark::Command::Repo );

use warnings;
use strict;

use Sark;

sub usage_text {
    "sark repo list"
}

sub run {
    my $sark = Sark->new();
    $sark->error("repo list not implemented yet");
}

1;


