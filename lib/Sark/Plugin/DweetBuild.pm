package Sark::Plugin::DweetBuild;
use Deeme::Obj -base;
use Sark;
use Sark::API::Interface::Dweet;
use Log::Log4perl;

has "name" => "DweetBuild";
has "logger" =>
    sub { Log::Log4perl->get_logger('Sark::Plugin::DweetBuild'); };
has "interface" => sub {
    my $self = shift;
    Sark::API::Interface::Dweet->new;
};

sub register {
    my ( $self, $sark ) = @_;

    $sark->emit( join( ".", "plugin", $self->name, "register" ) );
    $sark->on(
        "build.fail" => sub {
            my $build = $_[1];
            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "failed" );
        }
    );
    $sark->on(
        "build.prepare" => sub {
            my $build = $_[1];
            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "prepare" );
        }
    );
    $sark->on(
        "build.pre_clean" => sub {
            my $build = $_[1];
            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "pre_clean" );
        }
    );
    $sark->on(
        "build.compile" => sub {
            my $build = $_[1];

            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "compile" );
        }
    );
    $sark->on(
        "build.publish" => sub {
            my $build = $_[1];

            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "publish" );
        }
    );
    $sark->on(
        "build.post_clean" => sub {
            my $build = $_[1];

            return
                unless ( $_[1]->has_plugin( $self->name ) );
            $self->interface->thing( $build->id );
            $self->interface->dweet( status => "post_clean" );
        }
    );
}

1;
