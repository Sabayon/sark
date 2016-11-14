package Sark::Command::Repo::Disable;
use base qw( Sark::Command::Repo );

use warnings;
use strict;

use CLI::Framework::Exceptions qw( :all );
use Sark;

sub usage_text {
    "sark repo disable <repo_name> [...]";
}

sub validate {
    my ( $self, $cmd_opts, @args ) = @_;

    throw_cmd_validation_exception(
        error => "One or more repositories must be specified" )
        unless @args;
}

sub run {
    my $sark = Sark->new();
    $sark->error("repo disable not implemented yet");
}

1;

