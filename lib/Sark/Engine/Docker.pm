package Sark::Engine::Docker;
use Deeme::Obj 'Sark::Engine';
use Sark;
use Sark::API::Interface::Docker;
use Log::Log4perl;

has "name"      => "Docker";
has "logger"    => sub { Log::Log4perl->get_logger('Sark::Engine::Docker'); };
has "interface" => sub {
    Sark::API::Interface::Docker->new(
        Sark->instance->{config}->{data}->{docker}->{connection} );
};

sub prepare {

}

sub pre_clean {

}

sub compile {

}

sub publish {

}

sub post_clean {

}

1;
