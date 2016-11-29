package Sark::Plugin::Test1;

use Deeme::Obj -base;
use Locale::TextDomain 'Sark';

sub register {
    my ( $self, $sark ) = @_;

    # Send plugin.test.success when receiving a "plugin.test" event
    $sark->on(
        "plugin.test1" => sub { $sark->emit( "plugin.test1.success", "test" ); }
    );
}

1;
