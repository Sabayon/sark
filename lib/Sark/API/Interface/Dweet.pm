package Sark::API::Interface::Dweet;
use strict;
use Deeme::Obj -base;

use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;
use Carp;

has "address" => 'https://dweet.io';
has "thing"   => 'sarkdefault';

has "ua" => sub {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    $ua->agent('Mozilla/5.0');
    return $ua;
};

sub _uri {
    my ( $self, $rel, %options ) = @_;
    my $uri = URI->new( $self->address . "/" . $rel . "/" . $self->thing );
    $uri->query_form(%options);
    return $uri;
}

sub _parse {
    my ( $self, $uri, %options ) = @_;
    my $res = $self->ua->get( $self->_uri( $uri, %options ) );
    if ( $res->is_success ) {
        if ( $res->content_type eq 'application/json' ) {
            my $data = decode_json( $res->decoded_content );
            if (my $timed_out = _ratelimit(
                    $data, sub { return $self->_parse( $uri, %options ) }
                )
                )
            {
                return $timed_out;
            }
            return $data;
        }
        elsif ( $res->content_type eq 'text/plain' ) {
            my $data = eval { decode_json( $res->decoded_content ) };
            if (my $timed_out = _ratelimit(
                    $data, sub { return $self->_parse( $uri, %options ) }
                )
                )
            {
                return $timed_out;
            }
            return $data;
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
        my $json = JSON->new;
        return $json->incr_parse( $res->decoded_content );
    }
    my $message = $res->decoded_content;
    $message =~ s/\r?\n$//;
    croak $message;
}

sub dweet {
    my ( $self, %options ) = @_;

    my $input = encode_json( \%options );

    my $res = $self->ua->post(
        $self->_uri('/dweet/for/'),
        'Content-Type' => 'application/json',
        Content        => $input
    );
    if ( my $timed_out =
        _ratelimit( $res, sub { return $self->dweet(%options) } ) )
    {
        return $timed_out;
    }

    my $json = JSON->new;
    my $out  = $json->incr_parse( $res->decoded_content );
    return $out;
}

sub _ratelimit {
    my ( $out, $func ) = @_;
    if (    exists $out->{this}
        and exists $out->{because}
        and $out->{because} =~ /Rate limit/ )
    {
        sleep 1;
        return $func->();
    }
    return;
}

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

sub follow_link {
    my ( $self, %options ) = @_;
    return join( "/", $self->address, "follow", $self->thing );
}

sub dweets_link {
    my ( $self, %options ) = @_;
    return join( "/", $self->address, "get/dweets/for", $self->thing );
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
