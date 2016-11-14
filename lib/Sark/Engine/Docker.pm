package Sark::Engine::Docker;
use Deeme::Obj 'Sark::Engine';
use Sark;

sub register {
    my ( $self, $sark ) = @_;
    $sark->emit("engine.docker.register");
    $sark->on(
        "build.prepare" => sub {
            $sark->emit( "engine.docker.build.prepare", $self, @_ );
            $self->prepare( $_[0] );
        }
    );
    $sark->on(
        "build.configure" => sub {
            $sark->emit( "engine.docker.build.configure", $self, @_ );
            $self->configure( $_[0] );
        }
    );
    $sark->on(
        "build.compile" => sub {
            $sark->emit( "engine.docker.build.compile", $self, @_ );
            $self->compile( $_[0] );
        }
    );
}

sub prepare {

}

sub configure {

}

sub compile {

}

1;
