package Sark::Utils;
use base qw(Exporter);
our @EXPORT_OK = qw(uniq);

sub uniq {
    return keys %{ { map { $_ => 1 } @_ } };
}
1;
