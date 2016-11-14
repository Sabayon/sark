package Sark::Plugin::Test;

use Deeme::Obj -base;
use Locale::TextDomain 'Sark';

sub register {
    my ( $self, $sark ) = @_;

    # Send plugin.test.success when receiving a "plugin.test" event
    $sark->on(
        "plugin.test" => sub { $sark->emit( "plugin.test.success", "test" ); }
    );
}

1;
