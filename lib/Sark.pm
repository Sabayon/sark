package Sark;
use strict;
use Deeme::Obj 'Deeme';
use Sark::Loader;
use Locale::TextDomain 'Sark';
use utf8;
use Locale::Messages qw(bind_textdomain_filter);

BEGIN {
    # Force Locale::TextDomain to encode in UTF-8 and to decode all messages.
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'Sark' => \&Encode::decode_utf8;
}
our $VERSION = 0.01;

has 'plugins' => sub{()};

my $singleton;

sub new { $singleton ||= shift->SUPER::new(@_); }

sub emit {
    my $self = shift;

    $self->emit( "emit", @_ )
        if $_[0] ne "emit";    #this allows plugin to listen what happens
    $self->SUPER::emit(@_);

}

sub on_load {
    my $self = shift;
    $self->load_plugins;
}

sub load_plugins {
    my $self   = shift;
    my $Loader = Sark::Loader->new;
    if ( my @PLUGINS = $self->plugins ) {
        for (@PLUGINS) {
            my $Plugin = "Sark::Plugin::" . ucfirst($_);
            next if $Loader->load($Plugin);
            $Plugin->new->register($self);
        }
    }
}

*instance = \&new;
1;

=encoding utf-8

=head1 NAME

Sark - Sabayon Automatized Repository Kit

=head1 SYNOPSIS


=head1 DESCRIPTION

still nothing serious here :)

=head1 STRUCTURE

=over

=item blah

=item blablah

=back

=cut
