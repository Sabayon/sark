package Sark::Engine::Docker;
use Deeme::Obj 'Sark::Engine';
use Sark;
use Sark::API::Interface::Docker;

has "name" => "Docker";
has "interface" => sub { return Sark::API::Interface::Docker->new };

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
