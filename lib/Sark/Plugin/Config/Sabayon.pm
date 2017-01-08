package Sark::Plugin::Config::Sabayon;
use Deeme::Obj 'Sark::Plugin';
use Sark;
use Log::Log4perl;
use Sark::Utils qw(bool decamelize);

has "name" => "Config::Sabayon";
has "logger" =>
    sub { Log::Log4perl->get_logger('Sark::Plugin::Config::Sabayon'); };

sub register {
    my ( $self, $sark ) = @_;

    $sark->emit(
        join( ".", "plugin", decamelize( $self->name ), "register" ) );

    $sark->on(
        "build.prepare" => sub {

# First make sure engine has been explictly selected inside the build configuration.
# This avoids that all loaded engines are enabled for all builds(allowing parallel execution)
            return
                unless ( $_[1]->has_plugin( $self->name ) )
                ;    #$_[1] is the Sark::Build in this case
            my $build = $_[1];

            my $yaml = $build->_config;

            #XXX: Currently missing config fields in our Sark::Config model.

            # Read build configuration data,
            #decoded from YAML in the internal Sark::Build::Config

            $build->config->add( "USE_EQUO",
                bool( $yaml->{equo}->{dependency_install}->{enable} ) )
                if exists $yaml->{equo}->{dependency_install}->{enable};

            $build->config->add( "EQUO_INSTALL_ATOMS",
                bool( $yaml->{equo}->{dependency_install}->{install_atoms} ) )
                if
                exists $yaml->{equo}->{dependency_install}->{install_atoms};

        }
    );

}

1;
