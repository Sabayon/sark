package Sark::Build;
use Sark;
use Deeme::Obj -base;
use Data::UUID;
use Sark::Config;
use Sark::Build::Config;

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

sub prepare {
    my ( $self, @args ) = @_;

    # Search build section in yaml structure
    my $yaml = Sark->instance->{config}->search("build");

    #XXX: Currently missing config fields in our Sark::Config model.
    #XXX: Add methods to Sark::Config to dynamically add config blocks,
    # when

    # Read build configuration data,
    #decoded from YAML in the internal Sark::Build::Config
    # $self->config->add( "EMERGE_SPLIT_INSTALL",
    #     bool( $yaml->{emerge}->{split_install} ) )
    #     if exists $yaml->{emerge}->{split_install};
    # $self->config->add( "BUILDER_JOBS", $yaml->{emerge}->{jobs} )
    #     if exists $yaml->{emerge}->{jobs};
    # $self->config->add( "USE_EQUO",
    #     bool( $yaml->{equo}->{dependency_install}->{enable} ) )
    #     if exists $yaml->{equo}->{dependency_install}->{enable};
    # $self->config->add( "PRESERVED_REBUILD",
    #     bool( $yaml->{emerge}->{preserved_rebuild} ) )
    #     if exists $yaml->{emerge}->{preserved_rebuild};
    # $self->config->add( "EQUO_INSTALL_ATOMS",
    #     bool( $yaml->{equo}->{dependency_install}->{install_atoms} ) )
    #     if exists $yaml->{equo}->{dependency_install}->{install_atoms};
    # $self->config->add( "DEPENDENCY_SCAN_DEPTH",
    #     $yaml->{equo}->{dependency_install}->{dependency_scan_depth} )
    #     if
    #     exists $yaml->{equo}->{dependency_install}->{dependency_scan_depth};
    # $self->config->add( "BUILDER_JOBS", $yaml->{emerge}->{jobs} )
    #     if exists $yaml->{emerge}->{jobs};

    Sark->instance->emit( "build.prepare", @_ );
}

sub pre_clean { Sark->instance->emit( "build.pre_clean", @_ ) }

sub compile { Sark->instance->emit( "build.compile", @_ ) }

sub start { Sark->instance->emit( "build.start", @_ ) }

sub publish { Sark->instance->emit( "build.publish", @_ ) }

sub post_clean { Sark->instance->emit( "build.post_clean", @_ ) }

sub bail_out { Sark->instance->emit( "build.failed", @_ ) }

sub engines { my $self = shift; return $self->_config->{engines}; }

sub plugins { my $self = shift; return $self->_config->{plugins}; }

sub enable_plugin {
    my ( $self, $Plugin ) = @_;
    return $self unless !$self->has_plugin($Plugin);
    $self->_config->{plugins} =
        [ @{ $self->config->{plugins} }, ucfirst($Plugin) ];
    return $self;
}

sub enable_engine {
    my ( $self, $Engine ) = @_;
    return $self unless !$self->has_engine($Engine);
    $self->_config->{engines} =
        [ @{ $self->config->{engines} }, ucfirst($Engine) ];
    return $self;
}

sub docker { my $self = shift; return $self->_config->{docker}; }

1;
