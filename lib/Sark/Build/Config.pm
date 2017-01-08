package Sark::Build::Config;
use Deeme::Obj -base;

sub new {
    my $self = shift;

    my $class = $self->SUPER::new(@_);
    $class->{content} = {};
    return $class;
}

sub add {
    my ( $self, $key, $value ) = @_;
    $self->{content}->{$key} = $value;
    return $self;
}

sub remove {
    my ( $self, $key ) = @_;
    delete $self->{content}->{$key};
    return $self;
}

sub get {
    my ( $self, $key ) = @_;
    return exists $self->{content}->{$key} ? $self->{content}->{$key} : undef;
}

sub array {
    my $self = shift;
    my @array;
    foreach my $k ( keys %{ $self->{content} } ) {
        push( @array, ${k} . "=" . $self->{content}->{$k} );
    }
    return @array;
}

1;
