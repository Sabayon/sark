package Sark::API::Interface::Dweet;
use strict;
use Deeme::Obj -base;

use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;
use Carp;

has "address" => 'https://dweet.io/';
has "thing"   => 'sarkdefault';

has "ua" => sub {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    $ua->agent('Mozilla/5.0');
    return $ua;
};

sub _uri {
    my ( $self, $rel, %options ) = @_;
    my $uri = URI->new( $self->address . $rel . "/" . $self->thing );
    $uri->query_form(%options);
    return $uri;
}

sub _parse {
    my ( $self, $uri, %options ) = @_;
    my $res = $self->ua->get( $self->_uri( $uri, %options ) );
    if ( $res->is_success ) {
        if ( $res->content_type eq 'application/json' ) {
            return decode_json( $res->decoded_content );
        }
        elsif ( $res->content_type eq 'text/plain' ) {
            return eval { decode_json( $res->decoded_content ) };
        }
        elsif ( $res->content_type eq 'application/octet-stream' ) {
            return $res->content;
        }
    }
    else {
        return $res;
    }
    $res->dump;
}

sub _parse_request {
    my ( $self, $res ) = @_;
    if ( $res->content_type eq 'application/json' ) {
        my $json = JSON::XS->new;
        return $json->incr_parse( $res->decoded_content );
    }
    my $message = $res->decoded_content;
    $message =~ s/\r?\n$//;
    croak $message;
}

=method create

Creates a container. You can specify the options as an hash, following the Docker API specifications.

=cut

sub dweet {
    my ( $self, %options ) = @_;

    my $input = encode_json( \%options );

    my $res = $self->ua->post(
        $self->_uri('/dweet/for/'),
        'Content-Type' => 'application/json',
        Content        => $input
    );

    my $json = JSON::XS->new;
    my $out  = $json->incr_parse( $res->decoded_content );
    return $out;
}

=method ps

Returns the running containers. You can specify the options as an hash, following the Docker API specifications.

=cut

sub latest {
    my ( $self, %options ) = @_;
    my $res = $self->_parse( '/get/latest/dweet/for/', %options );

    return $res unless exists $res->{this} and $res->{this} eq "succeeded";
    return wantarray ? @{ $res->{with} } : $res->{with}->[0];
}

sub dweets {
    my ( $self, %options ) = @_;
    my $res = $self->_parse( '/get/dweets/for/', %options );

    return $res unless exists $res->{this} and $res->{this} eq "succeeded";
    return wantarray ? @{ $res->{with} } : $res->{with}->[0];
}

*uri = \&_uri;

1;

=head1 NAME

Sark::API::Interface::Dweet - Tiny interface to the Dweet.io API

=head1 SYNOPSIS

    use Sark::API::Interface::Dweet;

    my $thing = Sark::API::Interface::Dweet->new(thing=> "whatever");

    my $res = $api->dweet(
        my=> {
            weirdo=>{
            structure => "is there!"
          }
      }
    );

=head1 DESCRIPTION

Perl module for using the Docker Remote API.

=head1 AUTHOR

Ettore Di Giacinto E<lt>mudler@sabayon.orgE<gt>

=head1 COPYRIGHT

Copyright 2016 - Ettore Di Giacinto

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://docker.io>

=cut
