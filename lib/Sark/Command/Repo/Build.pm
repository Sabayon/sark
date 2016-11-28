package Sark::Command::Repo::Build;
use base qw( Sark::Command::Repo );

use warnings;
use strict;

use CLI::Framework::Exceptions qw( :all );
use Sark;
use Log::Log4perl;

sub usage_text {
    "sark repo build <repo_name> [...]";
}

sub validate {
    my ( $self, $cmd_opts, @args ) = @_;

    throw_cmd_validation_exception(
        error => "One or more repositories must be specified" )
        unless @args;
}

sub run {
    my ($opts, @args) = @_;
    
    my $sark = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Command::Repo::Build');
    $logger->error("repo build not implemented yet");
}

1;

