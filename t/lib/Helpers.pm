package Helpers;
use base qw(Exporter);
use Sark;
our @EXPORT_OK = qw( initialize );

sub initialize() {
    Sark->new->on_load;
    Sark->instance->emit("on_load");
}

1;
