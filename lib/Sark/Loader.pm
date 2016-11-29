package Sark::Loader;
use Deeme::Obj -base;

use File::Basename 'fileparse';
use File::Spec::Functions qw(catdir catfile splitdir);
use Carp;

my ( %BIN, %CACHE );
sub class_to_path { join '.', join( '/', split /::|'/, shift ), 'pm' }

sub load {
    my ( $self, $module ) = @_;

    my $logger = Log::Log4perl->get_logger('Sark::Loader');

    # Check module name
    if ( !$module || $module !~ /^\w(?:[\w:']*\w)?$/ ) {
        $logger->debug("Skipping module '${module}' due to invalid name");
        return 1;
    }

    # Load
    if ( $module->can('new') || eval "require $module; 1" ) {
        return undef;
    }

    # Exists
    if ( $@ =~ /^Can't locate \Q@{[class_to_path $module]}\E in \@INC/ ) {
        $logger->debug(
            "Failed to load ${module}, cannot locate file on disk");
        return 1;
    }

    # Real error
    return croak($@);
}

sub search {
    my ( $self, $ns ) = @_;

    my %modules;
    for my $directory (@INC) {
        next unless -d ( my $path = catdir $directory, split( /::|'/, $ns ) );

        # List "*.pm" files in directory
        opendir( my $dir, $path );
        for my $file ( grep /\.pm$/, readdir $dir ) {
            next if -d catfile splitdir($path), $file;
            $modules{ "${ns}::" . fileparse $file, qr/\.pm/ }++;
        }
        closedir $dir;
    }

    return keys %modules;
}

1;
