package Helpers;
use base qw(Exporter);
use Sark;
our @EXPORT_OK = qw( initialize );

sub initialize() {
    Sark->new->init;
}

1;
