package Sark::Plugin::PluginsEvent;

use Deeme::Obj 'Sark::Plugin';
use Locale::TextDomain 'Sark';
has events => sub {
    my $plugin = shift;
    {   "plugin.test2" => sub {

            $_[0]->emit( "plugin.test2.success", "test", $plugin->name );
        }

    };

};

1;
