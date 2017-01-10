package Sark::Plugin;

# ABSTRACT: ase class for Sark implementations

use Sark;
use Deeme::Obj -base;
has [qw( name events )];
use Log::Log4perl;
use Sark::Utils qw(camelize decamelize);

has logger => sub {
    my $self  = shift;
    my $class = "$self";
    $class =~ s/\=.*//g;
    return Log::Log4perl->get_logger($class);
};

sub register {
    my ( $self, $sark ) = @_;
    return unless ref( $self->events() ) eq "HASH";

    if ( !$self->name ) {
        my $class = "$self";
        $class =~ s/\=.*//g;
        my @c = split( /::/, $class );
        $self->name( camelize( join( "::", @c[ 2 .. $#c ] ) ) );
    }
    $sark->emit(
        join( ".", "plugin", decamelize( $self->name ), "register" ) );

    my @events = keys %{ $self->events() };

    foreach my $e (@events) {
        $sark->on( $e => $self->events()->{$e} );
    }
}
1;

__END__

=head1 DESCRIPTION

Sark is written in a technology-agnostic way so that future technologies can be used as drop in replacements. Each implementation will be written as a subclass of C<Sark::Plugin>, and will be invoked by interface methods at the appropriate points during a build.
=cut
