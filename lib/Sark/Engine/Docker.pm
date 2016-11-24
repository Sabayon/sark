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
        "build.pre_clean" => sub {
            $sark->emit( "engine.docker.build.pre_clean", $self, @_ );
            $self->pre_clean( $_[0] );
        }
    );
    $sark->on(
        "build.compile" => sub {
            $sark->emit( "engine.docker.build.compile", $self, @_ );
            $self->compile( $_[0] );
        }
    );
    $sark->on(
        "build.publish" => sub {
            $sark->emit( "engine.docker.build.publish", $self, @_ );
            $self->publish( $_[0] );
        }
    );
    $sark->on(
        "build.post_clean" => sub {
            $sark->emit( "engine.docker.build.post_clean", $self, @_ );
            $self->post_clean( $_[0] );
        }
    );
}

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
