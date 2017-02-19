package Sark::Build;

# ABSTRACT: Sark Build class. It holds all the build configurations,
# emits builds related events

use Sark;
use Deeme::Obj -base;
use Data::UUID;
use Sark::Config;
use Sark::Build::Config;
use Sark::Utils qw(camelize);

# 'id' holds the unique identifier for the build
has 'id' => sub {
    my $ug = Data::UUID->new;
    return $ug->create_str();
};

# 'config' holds the Sark::Build::Config that is used from plugins and engines
has "config"  => sub { Sark::Build::Config->new; };

# '_config' contains a reference to a part of the yaml read by Sark::Config
has "_config" => sub { Sark->instance->{config}->search("build"); };

# 'target' is the list of packages to compile
has "target" => sub { Sark->instance->{config}->search("target"); };

=method new

The C<new> method returns a new instance of Sark::Build.
With "engines" and "plugins" options it is possible to list modules that must be
enabled for the build to succeed.

  my $build = Sark::Build->new(plugin => [qw(Test1)]);

=cut

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

=method has_engine

C<has_engine> method returns true if the build has the supplied engine enabled.

=cut

sub has_engine {
    my $self   = shift;
    my $engine = shift;
    return grep( /$engine/i, @{ $self->engines } );
}

=method has_plugin

C<has_plugin> method returns true if the build has the supplied plugin enabled.

=cut

sub has_plugin {
    my $self   = shift;
    my $plugin = shift;
    return grep( /$plugin/i, @{ $self->plugins } );
}

=method prepare

C<prepare> method emits the 'build.prepare' event, propagates the arguments that receives.

=cut

sub prepare { Sark->instance->emit( "build.prepare", @_ ); }

=method pre_clean

C<pre_clean> method emits the 'build.pre_clean' event, propagates the arguments that receives.

=cut

sub pre_clean { Sark->instance->emit( "build.pre_clean", @_ ); }

=method compile

C<compile> method emits the 'build.compile' event, propagates the arguments that receives.

=cut

sub compile { Sark->instance->emit( "build.compile", @_ ); }

=method start

C<start> method emits the 'build.start' event, propagates the arguments that receives.

=cut

sub start { Sark->instance->emit( "build.start", @_ ); }

=method publish

C<publish> method emits the 'build.publish' event, propagates the arguments that receives.

=cut

sub publish { Sark->instance->emit( "build.publish", @_ ); }

=method post_clean

C<post_clean> method emits the 'build.post_clean' event, propagates the arguments that receives.

=cut

sub post_clean { Sark->instance->emit( "build.post_clean", @_ ); }

=method bail_out

C<bail_out> method emits the 'build.failed' event, propagates the arguments that receives.

=cut

sub bail_out { Sark->instance->emit( "build.failed", @_ ); }

=method engines

C<engines> method returns the build's requested engines.

=cut

sub engines { shift->_config->{engines}; }

=method plugins

C<plugins> method returns the build's requested plugins.

=cut

sub plugins { shift->_config->{plugins}; }

=method enable_plugin

C<enable_plugin> method enable the supplied plugin for the build.
In that way the build explictly requires the plugin received as argument.

=cut

sub enable_plugin {
    my ( $self, $Plugin ) = @_;
    $Plugin = camelize($Plugin);
    return $self unless !$self->has_plugin($Plugin);
    push(@{ $self->_config->{plugins} }, $Plugin);
    return $self;
}

=method enable_engine

C<enable_engine> method enable the supplied engine for the build.
In that way the build explictly requires the engine received as argument.

=cut

sub enable_engine {
    my ( $self, $Engine ) = @_;
    $Engine = camelize($Engine);
    return $self unless !$self->has_engine($Engine);
    push(@{ $self->_config->{engines} }, $Engine);
    return $self;
}

sub docker { shift->_config->{docker}; }

1;
