package Sark::Plugin::Test;

use Deeme::Obj -base;
use Locale::TextDomain 'Sark';

sub register {
    my ( $self, $sark ) = @_;
    $sark->emit( "plugin.test.success", "test" );
}

1;
