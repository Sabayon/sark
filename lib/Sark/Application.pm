package Sark::Application;

use warnings;
use strict;
use base qw( CLI::Framework );

sub option_spec {
    [ 'help|h'        => 'show help' ],
        [ 'quiet|q'   => 'produce script-friendly output' ],
        [ 'verbose|v' => 'show verbose output' ],
        [ 'debug|d'   => 'show debug output' ],
        ;
}

sub command_map {
    'repo' => 'Sark::Command::Repo',
        ;
}

sub usage_text {
    q{
OPTIONS
    -h --help       : show help text (context aware)
    -v --verbose    : show verbose output
    -d --debug      : show debug output
    
COMMANDS
    repo            : manage and build repositories
};
}

sub validate {
    my ( $self, $opts, @args ) = @_;

    # Show help and exit
    if ( $opts->{help} || keys %$opts == 0 ) {
        $self->render( $self->usage(@args) );
        exit;
    }
}

1;
