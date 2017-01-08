package Sark::Utils;

# ABSTRACT: Utility functions

use base qw(Exporter);
our @EXPORT_OK =
    qw(array_minus bool camelize decamelize filewrite hash_getkey uniq);

=func uniq( $value, ... )

Returns a copy of the arguments with all duplicates removed.
Order is undefined, sort the output if you need predictable ordering.

=cut

sub uniq {
    return keys %{ { map { $_ => 1 } @_ } };
}

=func bool( $value )

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

=item C<array_minus>

Returns the difference of the passed arrays A and B (only those
array elements that exist in A and do not exist in B).
If an empty array is returned, A is subset of B.

Function was proposed by Laszlo Forro <salmonix@gmail.com>.

=cut

sub array_minus(\@\@) {
    my %e = map { $_ => undef } @{ $_[1] };
    return grep( !exists( $e{$_} ), @{ $_[0] } );
}

=func hash_getkey( $hashref, $key )

Search the key in the hash returning the data structure inside it.

=cut

sub hash_getkey {
    my ( $hash, $string ) = @_;
    return unless ref($hash) ne "ARRAY";
    return unless ref($hash) eq "HASH";

    foreach my $k ( keys %{$hash} ) {
        return $hash->{$k} if $k eq $string;

        if ( my $res = hash_getkey( $hash->{$k}, $string ) ) {
            return $res;
        }

    }

}

sub filewrite($$@) {
    my ( $direction, $file, @content ) = @_;
    open FILE, "${direction}${file}" or return undef;
    print FILE @content;
    close FILE;
}

# From Mojo::Utility
sub camelize {
    my $str = shift;
    return $str if $str =~ /^[A-Z]/;

    # CamelCase words
    return join '::', map {
        join( '', map { ucfirst lc } split '_' )
    } split '-', $str;
}

sub decamelize {
    my $str = shift;
    return $str if $str !~ /^[A-Z]/;

    # snake_case words
    return join '-', map {
        join( '_', map {lc} grep {length} split /([A-Z]{1}[^A-Z]*)/ )
    } split '::', $str;
}

1;

=head1 DESCRIPTION

This module contains utility functions which don't have a better fit
elsewhere.
