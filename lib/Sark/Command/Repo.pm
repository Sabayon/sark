package Sark::Command::Repo;
use warnings;
use strict;
use base qw( CLI::Framework::Command );
use Sark;

sub usage_text {
    q{
SUBCOMMANDS
    list    : List known repositories
    enable  : Enable automated builds of a repository
    disable : Disable automated builds of a repository
    build   : Build one or more repositories
};
}


1;



