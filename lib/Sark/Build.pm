package Sark::Build;
use Sark;
use Deeme::Obj -base;
use Data::UUID;
use Sark::Config;
use Sark::Build::Config;
use Sark::Utils qw(camelize);

has 'id' => sub {
    my $ug = Data::UUID->new;
    return $ug->create_str();
};
has "config"  => sub { Sark::Build::Config->new; };
has "_config" => sub { Sark->instance->{config}->search("build"); };
has "target" => sub { Sark->instance->{config}->search("target"); };

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    # Be sure to Load engines/plugins requested by build.
    if ( ref( $self->engines() ) eq "ARRAY" ) {
        Sark->instance->load_engine($_) for @{ $self->engines() };
    }
    if ( ref( $self->plugins() ) eq "ARRAY" ) {
        Sark->instance->load_plugin($_) for @{ $self->plugins() };
    }
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

sub prepare { Sark->instance->emit( "build.prepare", @_ ); }

sub pre_clean { Sark->instance->emit( "build.pre_clean", @_ ); }

sub compile { Sark->instance->emit( "build.compile", @_ ); }

sub start { Sark->instance->emit( "build.start", @_ ); }

sub publish { Sark->instance->emit( "build.publish", @_ ); }

sub post_clean { Sark->instance->emit( "build.post_clean", @_ ); }

sub bail_out { Sark->instance->emit( "build.failed", @_ ); }

sub engines { shift->_config->{engines}; }

sub plugins { shift->_config->{plugins}; }

sub enable_plugin {
    my ( $self, $Plugin ) = @_;
    $Plugin = camelize($Plugin);
    return $self unless !$self->has_plugin($Plugin);
    push(@{ $self->_config->{plugins} }, $Plugin);
    return $self;
}

sub enable_engine {
    my ( $self, $Engine ) = @_;
    $Engine = camelize($Engine);
    return $self unless !$self->has_engine($Engine);
    push(@{ $self->_config->{engines} }, $Engine);
    return $self;
}

sub docker { shift->_config->{docker}; }

1;
