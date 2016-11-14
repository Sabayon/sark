package Sark;
use strict;
use Deeme::Obj 'Deeme';
use Sark::Loader;
use Locale::TextDomain 'Sark';
use utf8;
use Encode;
use Locale::Messages qw(bind_textdomain_filter);
use Term::ANSIColor;

BEGIN {
    # Force Locale::TextDomain to encode in UTF-8 and to decode all messages.
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'Sark' => \&Encode::decode_utf8;
}
our $VERSION = 0.01;

has [qw(plugin engine)];

# Singleton class
my $singleton;

sub new {
    $singleton ||= shift->SUPER::new(@_);
    $singleton->init if !$singleton->{INITIALIZED};
    $singleton->{LOG_LEVEL} = "info" if !$singleton->{LOG_LEVEL};
    $singleton;
}

# Re-emits emit events for further inspection and statistics plugin.
# this eventually will go in a separate plugin
sub emit {
    my $self = shift;

    $self->emit( "emit", @_ )
        if $_[0] ne "emit";    #this allows plugin to listen what happens
    $self->SUPER::emit(@_);

}

# Init sequence when initialized first time
sub init {
    my $self = shift;
    $self->_register_namespace("Plugin");
    $self->_register_namespace("Engine");
    $self->emit("init");
    $singleton->{INITIALIZED}++;
    return $self;
}

# Register an entire Sark::namespace
sub _register_namespace {
    my ( $self, $ns ) = @_;
    my $ns_lc = lc($ns);
    if ( my @PLUGINS = $self->$ns_lc ) {
        for (@PLUGINS) {
            next if !defined $_;
            $self->_register_module( "Sark::${ns}::" . ucfirst($_) );
        }
    }
}

# Register a single module. e.g. Sark::Engine::Docker
sub _register_module {
    my ( $self, $Plugin ) = @_;
    return if Sark::Loader->new->load($Plugin);
    my $inst = $Plugin->new;
    $inst->register($self) if ( $inst->can("register") );
}

# Register a plugin/engine
sub load_plugin {
    my ( $self, $Plugin ) = @_;
    $self->_register_module("Sark::Plugin::${Plugin}");
}

sub load_engine {
    my ( $self, $Plugin ) = @_;
    $self->_register_module("Sark::Engine::${Plugin}");
}

sub error {
    my $self = shift;
    my @msg  = @_;
    if ( $self->{LOG_LEVEL} eq "info" ) {
        print STDERR color 'bold red';
        print STDERR encode_utf8('☢☢☢ ☛  ');
        print STDERR color 'bold white';
        print STDERR join( "\n", @msg ), "\n";
        print STDERR color 'reset';
    }
    elsif ( $self->{LOG_LEVEL} eq "quiet" ) {
        print join( "\n", @msg ), "\n";
    }
}

sub info {
    my $self = shift;

    my @msg = @_;
    if ( $self->{LOG_LEVEL} eq "info" ) {
        print color 'bold green';
        print encode_utf8('╠ ');
        print color 'bold white';
        print join( "\n", @msg ), "\n";
        print color 'reset';
    }
    elsif ( $self->{LOG_LEVEL} eq "quiet" ) {
        print join( "\n", @msg ), "\n";
    }
}

sub notice {
    my $self = shift;
    my @msg  = @_;
    if ( $self->{LOG_LEVEL} eq "info" ) {
        print STDERR color 'bold yellow';
        print STDERR encode_utf8('☛ ');
        print STDERR color 'bold white';
        print STDERR join( "\n", @msg ), "\n";
        print STDERR color 'reset';
    }
    elsif ( $self->{LOG_LEVEL} eq "quiet" ) {
        print STDERR join( "\n", @msg ), "\n";
    }
}

sub loglevel {
    my $self = shift;

    $self->{LOG_LEVEL} = $_[0] if $_[0];

    return $self->{LOG_LEVEL};
}

*instance = \&new;
1;

=encoding utf-8

=head1 NAME

Sark - Sabayon Automatized Repository Kit

=head1 VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

This project provides the tools required to automatically build Sabayon
Entropy repositories, including the
L<Sabayon Community Repositories|https://sabayon.github.io/community-website/>.

=head1 GETTING STARTED

For local development, you will need some additional dependencies not yet
available in entropy. If using bash, you can use C<tools/bootstap.sh> to
install all necessary dependencies locally (no root requured).

 source tools/bootstrap.sh

This will take care of the following things:

=over

=item *

Set environment variables to use C<.bundle> directory to store dependencies

=item *

Install L<App::Cpanminus> and L<Local::Lib>

=item *

Install L<Dist::Zilla>

=item *

Install all C<sark> dependencies

=back

To remove any changes made by the bootstrap script, delete the C<.bundle>
directory in the project root, and restart your shell.

=head1 Running Tests

 dzil test

=cut
