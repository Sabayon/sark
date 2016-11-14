package Sark::Build;
use Sark;
use Deeme::Obj -base;
has [qw( id targets engine )];

sub prepare { Sark->instance->emit( "build.prepare", @_ ) }

sub configure { Sark->instance->emit( "build.configure", @_ ) }

sub compile { Sark->instance->emit( "build.compile", @_ ) }

1;
