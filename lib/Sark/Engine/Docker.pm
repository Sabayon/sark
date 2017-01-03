package Sark::Engine::Docker;
use Deeme::Obj 'Sark::Engine';
use Sark;
use Sark::API::Interface::Docker;
use Log::Log4perl;

has "name"      => "Docker";
has "logger"    => sub { Log::Log4perl->get_logger('Sark::Engine::Docker'); };
has "config"    => sub { Sark->instance->{config}->search("docker") };
has "interface" => sub {
    my $self = shift;
    Sark::API::Interface::Docker->new( $self->config->{connection} );
};

sub prepare {
    my ( $self, $build, @args ) = @_;
}

sub pre_clean {
    my ( $self, $build, @args ) = @_;

}

sub compile {
    my ( $self, $build, @args ) = @_;

}

sub start {
    my ( $self, $build, @args ) = @_;
}

sub publish {
    my ( $self, $build, @args ) = @_;

}

sub post_clean {
    my ( $self, $build, @args ) = @_;

}

1;
