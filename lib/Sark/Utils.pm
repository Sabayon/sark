package Sark::Utils;

# ABSTRACT: Utility functions

use base qw(Exporter);
our @EXPORT_OK = qw(bool uniq);

=func uniq( $value, ... )

Returns a copy of the arguments with all duplicates removed.
Order is undefined, sort the output if you need predictable ordering.

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
    elsif ( $value =~ /^(y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON)$/ ) {
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
