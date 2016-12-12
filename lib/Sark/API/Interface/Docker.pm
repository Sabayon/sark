package Sark::API::Interface::Docker;
use strict;
use Deeme::Obj -base;

use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;
use Carp;

has "address" => sub { $ENV{DOCKER_HOST} || 'http:/var/run/docker.sock/' };
has "ua" => sub {
    my $self = shift;
    if ( $self->address !~ m!http://! ) {
        require LWP::Protocol::http::SocketUnixAlt;
        LWP::Protocol::implementor(
            http => 'LWP::Protocol::http::SocketUnixAlt' );
    }
    my $ua = LWP::UserAgent->new;
    return $ua;
};

sub _uri { my $self = shift; return $self->uri(@_); }

sub uri {
    my ( $self, $rel, %options ) = @_;
    my $uri = URI->new( $self->address . $rel );
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

sub create {
    my ( $self, %options ) = @_;
    $options{AttachStderr} //= \1;
    $options{AttachStdout} //= \1;
    $options{AttachStdin}  //= \0;
    $options{OpenStdin}    //= \0;
    $options{Tty}          //= \1;

    ## workaround for an odd API implementation of
    ## container naming
    my %query;
    if ( my $name = delete $options{Name} ) {
        $query{name} = $name;
    }

    my $input = encode_json( \%options );

    my $res = $self->ua->post(
        $self->uri( '/containers/create', %query ),
        'Content-Type' => 'application/json',
        Content        => $input
    );

    my $json = JSON::XS->new;
    my $out  = $json->incr_parse( $res->decoded_content );
    return $out->{Id};
}

=method ps

Returns the running containers. You can specify the options as an hash, following the Docker API specifications.

=cut

sub containers {
    my ( $self, %options ) = @_;
    return $self->_parse( '/containers/json', %options );
}

=method images

Returns the available images on the host. You can specify the options as an hash, following the Docker API specifications.

=cut

sub images {
    my ( $self, %options ) = @_;
    return $self->_parse( '/images/json', %options );
}

sub images_viz {
    my ( $self, %options ) = @_;
    return $self->_parse( '/images/viz', %options );
}

sub search {
    my ( $self, %options ) = @_;
    return $self->_parse( '/images/search', %options );
}

sub history {
    my ( $self, $image, %options ) = @_;
    return $self->_parse( '/images/' . $image . '/history', %options );
}

sub inspect {
    my ( $self, $image, %options ) = @_;
    return $self->_parse( '/images/' . $image . '/json', %options );
}

sub version {
    my ( $self, %options ) = @_;
    return $self->_parse( '/version', %options );
}

sub info {
    my ( $self, %options ) = @_;
    return $self->_parse( '/info', %options );
}

sub inspect_container {
    my ( $self, $name, %options ) = @_;
    return $self->_parse( '/containers/' . $name . '/json', %options );
}

sub export {
    my ( $self, $name, %options ) = @_;
    return $self->_parse( '/containers/' . $name . '/export', %options );
}

sub diff {
    my ( $self, $name, %options ) = @_;
    return $self->_parse( '/containers/' . $name . '/changes', %options );
}

sub remove_image {
    my ( $self, @names ) = @_;
    for my $image (@names) {
        $self->ua->request(
            HTTP::Request->new(
                'DELETE', $self->_uri( '/images/' . $image )
            )
        );
    }
    return;
}

sub remove_container {
    my ( $self, @names ) = @_;
    for my $container (@names) {
        $self->ua->request(
            HTTP::Request->new(
                'DELETE', $self->_uri( '/containers/' . $container )
            )
        );
    }
    return;
}

sub pull {
    my ( $self, $repository, $tag, $registry ) = @_;

    if ( $repository =~ m/:/ ) {
        ( $repository, $tag ) = split /:/, $repository;
    }
    my %options = (
        fromImage => $repository,
        tag       => $tag,
        registry  => $registry,
    );
    my $uri = '/images/create';
    my $res = $self->ua->post( $self->_uri( $uri, %options ) );
    return $self->_parse_request($res);
}

sub start {
    my ( $self, $name, %options ) = @_;
    $self->ua->post(
        $self->_uri( '/containers/' . $name . '/start', %options ) );
    return;
}

sub stop {
    my ( $self, $name, %options ) = @_;
    $self->ua->post(
        $self->_uri( '/containers/' . $name . '/stop', %options ) );
    return;
}

sub logs {
    my ( $self, $container ) = @_;
    my %params = (
        logs   => 1,
        stdout => 1,
        stderr => 1,
    );
    my $url = $self->_uri( '/containers/' . $container . '/attach' );
    my $res = $self->ua->post( $url, \%params );
    return $res->content;
}

1;

=head1 NAME

Sark::API::Interface::Docker - Tiny interface to the Docker API

=head1 SYNOPSIS

    use Sark::API::Interface::Docker;

    my $api = Sark::API::Interface::Docker->new;

    my $id = $api->create(
        Image       => 'ubuntu',
        Cmd         => ['/bin/bash'],
        AttachStdin => \1,
        OpenStdin   => \1,
        Name        => 'my-container',
    );

    say $id;
    $api->start($id);


=head1 DESCRIPTION

Perl module for using the Docker Remote API.

=head1 AUTHOR

Peter Stuifzand E<lt>peter@stuifzand.euE<gt>
Ettore Di Giacinto E<lt>mudler@sabayon.orgE<gt>

=head1 COPYRIGHT

Copyright 2013 - Peter Stuifzand
Copyright 2016 - Ettore Di Giacinto

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://docker.io>

=cut
