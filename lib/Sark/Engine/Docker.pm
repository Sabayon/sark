package Sark::Engine::Docker;
use Deeme::Obj 'Sark::Engine';
use Sark;
use Sark::API::Interface::Docker;

has "config" => sub { Sark->instance->{config}->{data} };
has "docker" => sub {
    my $self = shift;
    Sark::API::Interface::Docker->new(
        address => $self->config->{docker}->{connection} );
};

sub prepare {
    my ( $self, $build, @args ) = @_;

    # Check docker connection
    my $api;
    my $checkv;
    eval {
        $api = Sark::API::Interface::Docker->new(
            $self->config->{docker}->{connection} );
        $checkv = $api->version()->{Version};
    };

    if ( !$api or $@ or !$checkv ) {
        $self->logger->error(
            "Cannot connect to docker ! The host specified in configuration is: "
                . $self->config->{docker}->{connection} );
        exit 1;
    }

}

sub pre_clean {
    my ( $self, $build, @args ) = @_;

}

sub compile {
    my ( $self, $build, @args ) = @_;

}

sub start {
    my ( $self, $build, @args ) = @_;

    # Get building configuration from the build class as an array.
    my @build_config = $build->config->array;

    # Generate docker runtime configuration
    my %config;

    $config{HostConfig}{CapAdd} = $_
        for @{ $self->config->{docker}->{capabilities} };
    $config{Entrypoint} = $self->config->{docker}->{entrypoint}
        if $self->config->{docker}->{entrypoint};
    $config{Volumes} = $self->config->{docker}->{volumes}
        if $self->config->{docker}->{volumes};
    $config{Image} = $self->config->{docker}->{image}
        if $self->config->{docker}->{image};
    $config{Env} = [@build_config];

    # copy the remaining in opts.
    if ( ref( $self->config->{docker}->{opts} ) eq "HASH" ) {
        $config{$_} = $self->config->{docker}->{opts}->{$_}
            for keys %{ $self->config->{docker}->{opts} };
    }

    #my $container = $self->docker()->create(%config);

}

sub publish {
    my ( $self, $build, @args ) = @_;

}

sub post_clean {
    my ( $self, $build, @args ) = @_;

}

1;
