package Sark::Build;
use Sark;
use Deeme::Obj -base;
has [qw( id config engine )];

sub prepare { Sark->instance->emit( "build.prepare", @_ ) }

sub pre_clean { Sark->instance->emit( "build.pre_clean", @_ ) }

sub compile { Sark->instance->emit( "build.compile", @_ ) }

sub publish { Sark->instance->emit( "build.publish", @_ ) }

sub post_clean { Sark->instance->emit( "build.post_clean", @_ ) }

1;
