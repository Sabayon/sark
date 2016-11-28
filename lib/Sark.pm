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

BEGIN {
    # Force Locale::TextDomain to encode in UTF-8 and to decode all messages.
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'Sark' => \&Encode::decode_utf8;
}
our $VERSION = 0.01;

has [qw(plugin engine)];

# Singleton class
my $singleton;

sub new {
    my $class = shift;
    
    $singleton ||= $class->SUPER::new(@_);
    if ( ! $singleton->{INITIALIZED} ) {
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
    if ($self->{LOG_DEBUG}) {
        $log_level = 'DEBUG';
    } elsif ($self->{LOG_VERBOSE}) {
        $log_level = 'INFO';
    } else {
        $log_level = 'WARN';
    }
    
    my $screen_layout_pattern = '[%p %c] %m%n';
    if ($self->{LOG_QUIET}) {
        $screen_layout_pattern = '%m%n';
    }
    
    my $logger;
    if ( -f $self->{LOGGING_CONFIG_FILE}) {
        Log::Log4perl->init($self->{LOGGING_CONFIG_FILE});
        $logger = Log::Log4perl->get_logger();

        # If --verbose or --debug cli options were present, override
        # the log level from the config file here
        if ($self->{LOG_DEBUG} || $self->{LOG_VERBOSE}) {
            $logger->level($log_level);
        }
    } else {
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
        $logger = Log::Log4perl->get_logger();
        $logger->warn("No logging config file present, falling back to default logging. Create $ENV{HOME}/sark/logging.conf, or specify --logging_config to an alternate location to customise logging and suppress this message.");
    }
    
    $logger->debug("Logging initialized");
    
    $self->_register_namespace("Plugin");
    $self->_register_namespace("Engine");
    
    $self->{config} = Sark::Config->new;
    $self->{config}->load_from_config_file($self->{CONFIG_FILE});
    
    $self->emit("init");
    $singleton->{INITIALIZED}++;
}

# Register an entire Sark::namespace
sub _register_namespace {
    my ( $self, $ns ) = @_;
    my $ns_lc = lc($ns);
    if ( my @PLUGINS = $self->$ns_lc ) {
        for (@PLUGINS) {
            next if !defined $_;
            $self->_register_module( "Sark::${ns}::" . ucfirst($_) );
        }
    }
}

# Register a single module. e.g. Sark::Engine::Docker
sub _register_module {
    my ( $self, $Plugin ) = @_;
    return if Sark::Loader->new->load($Plugin);
    my $inst = $Plugin->new;
    $inst->register($self) if ( $inst->can("register") );
}

# Register a plugin/engine
sub load_plugin {
    my ( $self, $Plugin ) = @_;
    $self->_register_module("Sark::Plugin::${Plugin}");
}

sub load_engine {
    my ( $self, $Plugin ) = @_;
    $self->_register_module("Sark::Engine::${Plugin}");
}

sub bool {
    my $value = shift // 0;
    
    if ($value == 1) {
        return 1;
    } elsif ($value == 0) {
        return 0;
    } elsif ($value =~ /^(?:y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|)$/) {
        return 1;
    } else {
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
