package Sark;
use strict;
use Carp;
use Deeme::Obj 'Deeme';
use Locale::TextDomain 'Sark';
use utf8;
use Encode;
use Locale::Messages qw(bind_textdomain_filter);
use Term::ANSIColor;
use Log::Log4perl;

use Sark::Config;
use Sark::Loader;
use Sark::Utils qw(uniq);

BEGIN {
    # Force Locale::TextDomain to encode in UTF-8 and to decode all messages.
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'Sark' => \&Encode::decode_utf8;
}
our $VERSION = 0.01;

# plugin and engine are the Sark runtime loaded plugin/engines list.
# If filled, will load the declared plugins/engines in runtime when creating the instance
has [qw(plugin engine)] => sub { [] };

# Singleton class
my $singleton;

sub new {
    my $class = shift;

    $singleton ||= $class->SUPER::new(@_);
    if ( !$singleton->{INITIALIZED} ) {
        $singleton->init;
    }

    return $singleton;
}

# Re-emits emit events for further inspection and statistics plugin.
# this eventually will go in a separate plugin
sub emit {
    my $self = shift;

    $self->emit( "emit", @_ )
        if $_[0] ne "emit";    #this allows plugin to listen what happens
    $self->SUPER::emit(@_);

}

# Init sequence when initialized first time
sub init {
    my $self = shift;

    $self->{CONFIG_FILE}         //= "$ENV{HOME}/sark/config.yaml";
    $self->{LOGGING_CONFIG_FILE} //= "$ENV{HOME}/sark/logging.conf";
    $self->{LOG_QUIET}           //= 0;
    $self->{LOG_VERBOSE}         //= 0;
    $self->{LOG_DEBUG}           //= 0;

    my $log_level;
    if ( $self->{LOG_DEBUG} ) {
        $log_level = 'DEBUG';
    }
    elsif ( $self->{LOG_VERBOSE} ) {
        $log_level = 'INFO';
    }
    else {
        $log_level = 'WARN';
    }

    my $screen_layout_pattern = '[%p %c] %m%n';
    if ( $self->{LOG_QUIET} ) {
        $screen_layout_pattern = '%m%n';
    }

    if ( -f $self->{LOGGING_CONFIG_FILE} ) {
        Log::Log4perl->init_once( $self->{LOGGING_CONFIG_FILE} );
        $self->{logger} = Log::Log4perl->get_logger();

        # If --verbose or --debug cli options were present, override
        # the log level from the config file here
        if ( $self->{LOG_DEBUG} || $self->{LOG_VERBOSE} ) {
            $self->{logger}->level($log_level);
        }
    }
    else {
        my $default_logging_config = <<END;
log4perl.category                  = $log_level, Logfile, Screen

log4perl.appender.Logfile          = Log::Log4perl::Appender::File
log4perl.appender.Logfile.filename = $ENV{HOME}/sark/logs/sark.log
log4perl.appender.Logfile.mkpath   = 1
log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Logfile.layout.ConversionPattern = [\%d \%p \%c] \%m\%n

log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr  = 1
log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = $screen_layout_pattern
END

        Log::Log4perl->init( \$default_logging_config );
        $self->{logger} = Log::Log4perl->get_logger();
        $self->{logger}->info(
            "Using default logging. Create $ENV{HOME}/sark/logging.conf,"
                . " or use --logging_config to specify an alternate location"
                . "to customise logging and suppress this message." );
    }

    $self->{logger}->debug("Logging initialized");

    $self->{config} = Sark::Config->new;
    $self->{config}->load_from_config_file( $self->{CONFIG_FILE} );

    $self->_register_namespace(
        "Sark::Engine",
        uniq(
            @{ $self->{config}->{data}->{build}->{engines} },
            @{ $self->engine() }
        )
    );
    $self->_register_namespace(
        "Sark::Plugin",
        uniq(
            @{ $self->{config}->{data}->{build}->{plugins} },
            @{ $self->plugin() }
        )
    );

    $self->emit("init");
    $singleton->{INITIALIZED}++;
    return $self;
}

# Register an entire Sark::namespace
sub _register_namespace {
    my ( $self, $ns, @modules ) = @_;

    # If no modules are provided, load them all
    #
    # @modules = Sark::Loader->search($ns) unless @modules > 0;
    my $group = lc( ( split( /::/, $ns ) )[1] ); # Get plugin/engine namespace

    for (@modules) {
        next unless defined $_;
        if ( $group eq "engine" ) {
            $self->load_engine( ucfirst( lc( ( split( /::/, $_ ) )[-1] ) ) )
                ; # load the engine/plugin, take its name from the last position from the array formed by the split of "::" from the package name;
        }
        elsif ( $group eq "plugin" ) {
            $self->load_plugin( ucfirst( lc( ( split( /::/, $_ ) )[-1] ) ) );
        }
    }
}

# Register a single module. e.g. Sark::Engine::Docker
sub _register_module {
    my ( $self, $Plugin ) = @_;
    return if Sark::Loader->new->load($Plugin);
    my $inst = $Plugin->new;

    if ( $inst->can("register") ) {
        $inst->register($self);
        $self->{logger}->info("Registered module $Plugin");
    }
    else {
        $self->{logger}
            ->debug("Skipped module $Plugin: no 'register' method.");
        return 0;
    }
    return 1;
}

# Register a plugin/engine
sub load_plugin {
    my ( $self, $Plugin ) = @_;
    $self->plugin( [ @{ $self->plugin() }, ucfirst($Plugin) ] )
        unless !$self->_register_module("Sark::Plugin::${Plugin}");
    return $self;
}

sub load_engine {
    my ( $self, $Plugin ) = @_;
    $self->engine( [ @{ $self->engine() }, ucfirst($Plugin) ] )
        unless !$self->_register_module("Sark::Engine::${Plugin}");
    return $self;
}

sub loaded {
    my ( $self, $Plugin ) = @_;

    return 0 if !@{ $self->plugin } and !@{ $self->engine };
    foreach my $plugin_loaded ( @{ $self->plugin() }, @{ $self->engine() } ) {
        return 1 if ( $plugin_loaded eq $Plugin );
    }
    return 0;
}

sub bool {
    my $value = shift // 0;

    if ( $value == 1 ) {
        return 1;
    }
    elsif ( $value == 0 ) {
        return 0;
    }
    elsif ( $value =~ /^(?:y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|)$/ ) {
        return 1;
    }
    else {
        return 0;
    }

}

*instance = \&new;
1;

=encoding utf-8

=head1 NAME

Sark - Sabayon Automatized Repository Kit

=head1 VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

This project provides the tools required to automatically build Sabayon
Entropy repositories, including the
L<Sabayon Community Repositories|https://sabayon.github.io/community-website/>.

=head1 GETTING STARTED

For local development, you will need some additional dependencies not yet
available in entropy. If using bash, you can use C<tools/bootstap.sh> to
install all necessary dependencies locally (no root requured).

 source tools/bootstrap.sh

This will take care of the following things:

=over

=item *

Set environment variables to use C<.bundle> directory to store dependencies

=item *

Install L<App::Cpanminus> and L<Local::Lib>

=item *

Install L<Dist::Zilla>

=item *

Install all C<sark> dependencies

=back

To remove any changes made by the bootstrap script, delete the C<.bundle>
directory in the project root, and restart your shell.

=head1 Running Tests

 dzil test

=cut
