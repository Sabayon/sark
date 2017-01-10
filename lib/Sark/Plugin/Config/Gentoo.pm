package Sark::Plugin::Config::Gentoo;
use Deeme::Obj 'Sark::Plugin';
use Sark;
use Sark::Utils qw(bool decamelize);

has events => sub {
    {   "build.prepare" => sub {
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
    };

};

1;
