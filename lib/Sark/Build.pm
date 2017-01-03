package Sark::Build;
use Sark;
use Deeme::Obj -base;
use Data::UUID;

has 'id' => sub {
    my $ug = Data::UUID->new;
    return $ug->create_str();
};
has "config" => sub { Sark->instance->{config}->search("build"); };

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    # Be sure to Load engines/plugins requested by build.
    Sark->instance->load_engine($_) for @{ $self->engines() };
    Sark->instance->load_plugin($_) for @{ $self->plugins() };

    return $self;
}

sub has_engine {
    my $self   = shift;
    my $engine = shift;
    return grep( /$engine/i, @{ $self->engines } );
}

sub has_plugin {
    my $self   = shift;
    my $plugin = shift;
    return grep( /$plugin/i, @{ $self->plugins } );
}

sub prepare { Sark->instance->emit( "build.prepare", @_ ) }

sub pre_clean { Sark->instance->emit( "build.pre_clean", @_ ) }

sub compile { Sark->instance->emit( "build.compile", @_ ) }

sub start { Sark->instance->emit( "build.start", @_ ) }

sub publish { Sark->instance->emit( "build.publish", @_ ) }

sub post_clean { Sark->instance->emit( "build.post_clean", @_ ) }

sub bail_out { Sark->instance->emit( "build.failed", @_ ) }

sub engines { my $self = shift; return $self->config->{engines}; }

sub plugins { my $self = shift; return $self->config->{plugins}; }

sub enable_plugin {
    my ( $self, $Plugin ) = @_;
    return $self unless !$self->has_plugin($Plugin);
    $self->config->{plugins} =
        [ @{ $self->config->{plugins} }, ucfirst($Plugin) ];
    return $self;
}

sub enable_engine {
    my ( $self, $Engine ) = @_;
    return $self unless !$self->has_engine($Engine);
    $self->config->{engines} =
        [ @{ $self->config->{engines} }, ucfirst($Engine) ];
    return $self;
}

sub docker { my $self = shift; return $self->config->{docker}; }

1;
