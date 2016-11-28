package Sark::Application;

# ABSTRACT: command line interface entry point

use warnings;
use strict;
use base qw( CLI::Framework );

use Sark;

=method option_spec

This hook defines the global options and arguments. Subcommand-specific
options/arguments are handled

=cut

sub option_spec {
    (
        [ 'help|h'     => 'show help' ],
        [ 'quiet|q'    => 'produce script-friendly output', {
            default => 0,
        }],
        [ 'verbose|v'  => 'show verbose output', {
            default => 0,
        }],
        [ 'debug|d'    => 'show debug output', {
            default => 0,
        }],
        [ 'config|c=s' => 'config file', {
            default => "$ENV{HOME}/sark/config.yaml",
        }],
        [ 'logging_config|l=s' => 'logging config file', {
            default => "$ENV{HOME}/sark/logging.conf",
        }],
    );
}

=method command_map

This hook maps subcommane names/aliases to the implementation classes.

=cut

sub command_map {
    (
        'repo' => 'Sark::Command::Repo',
    );
}

=method usage_text

This hook is called when the usage text is needed (either because
sark was invoked with --help, or within incorrect options/arguments).

=cut

sub usage_text {
    q{
OPTIONS
    -h --help       : show help text (context aware)
    -q --quiet      : produce script-friendly output
    -v --verbose    : show verbose output
    -d --debug      : show debug output
    -c --config=$HOME/sark/config.yaml
                    : path to the sark configuration file
    -l --logging_config=$HOME/sark/logging.conf
                    : path to the sark logging config file
    
COMMANDS
    repo            : manage and build repositories
    };
}

=method validate

This hook validates the combination of global options and arguments.

=cut

sub validate {
    my ( $self, $opts, @args ) = @_;

    # Show help and exit
    if ( $opts->{help} || keys %$opts == 0 ) {
        $self->render( $self->usage(@args) );
        exit;
    }
}

=method init( $opts )

This hook is called before the C<run()> method of the chosen subcommand.
It is used to initialize the Sark singleton with the global config
options.

=cut

sub init {
    my ($self, $opts) = @_;
    
    # This will be the first time Sark is accessed
    # so pass in the configuration options to initialize it
    my $sark = Sark->new({
        CONFIG_FILE         => $opts->{config},
        LOGGING_CONFIG_FILE => $opts->{logging_config},
        LOG_QUIET           => $opts->{quiet},
        LOG_VERBOSE         => $opts->{verbose},
        LOG_DEBUG           => $opts->{debug},
    });
}

=method render( $output )

Takes a hashref, and prints all lines within the C<lines> keys
separated by newlines.

TODO: template this, using the C<template> key as the template filename.

=cut

sub render {
    my ($self, $output) = @_;
    
    if (ref($output) eq "HASH") {
        print join("\n", @{$output->{lines}}), "\n";
    } else {
        die $output;
    }
}

1;

=head1 DESCRIPTION

This class defines the main command line entry point into Sark. While
most of the work is done by subclasses, this class sets up the global
cli options/arguments, intializes the Sark core.
