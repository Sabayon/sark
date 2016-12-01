package Sark::Utils;

# ABSTRACT: Utility functions

use base qw(Exporter);
our @EXPORT_OK = qw(bool uniq);

=func uniq( $arr )

Takes in a list and returns a copy with all duplicate elements removed.

=cut

sub uniq {
    return keys %{ { map { $_ => 1 } @_ } };
}

=func bool( $value)

Takes a YAML-compatible boolean value and returns 1 for any of the recognised
true values, and 0 for everything else.

=cut

sub bool {
    my $value = shift // 0;

    if ( $value == 1 ) {
        return 1;
    }
    elsif ( $value == 0 ) {
        return 0;
    }
    elsif ( $value =~ /^(?:y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON|)$/ ) {
        return 1;
    }
    else {
        return 0;
    }

}

1;

=head1 DESCRIPTION

This module contains utility functions which don't have a better fit
elsewhere.
