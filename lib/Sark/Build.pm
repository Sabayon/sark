package Sark::Build;
use Sark;
use Deeme::Obj -base;
has [qw( id targets )];

sub compile { Sark->instance->emit( "build.compile", @_ ) }

sub test { Sark->instance->emit( "build.test", @_ ) }

1;
