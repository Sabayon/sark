package Sark::Plugin::Config::Gentoo;
use Deeme::Obj 'Sark::Plugin';
use Sark;
use Log::Log4perl;
use Sark::Utils qw(bool decamelize);

has "name" => "Config::Gentoo";
has "logger" =>
    sub { Log::Log4perl->get_logger('Sark::Plugin::Config::Gentoo'); };

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
            $build->config->add( "EMERGE_SPLIT_INSTALL",
                bool( $yaml->{emerge}->{split_install} ) )
                if exists $yaml->{emerge}->{split_install};
            $build->config->add( "BUILDER_JOBS", $yaml->{emerge}->{jobs} )
                if exists $yaml->{emerge}->{jobs};
            $build->config->add( "PRESERVED_REBUILD",
                bool( $yaml->{emerge}->{preserved_rebuild} ) )
                if exists $yaml->{emerge}->{preserved_rebuild};
            $build->config->add( "DEPENDENCY_SCAN_DEPTH",
                $yaml->{equo}->{dependency_install}->{dependency_scan_depth} )
                if exists $yaml->{equo}->{dependency_install}
                ->{dependency_scan_depth};
        }
    );

}

1;
