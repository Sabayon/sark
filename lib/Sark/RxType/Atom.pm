package Sark::RxType::Atom;
use parent 'Data::Rx::CommonType::EasyNew';
use Data::Rx::Failure;

sub type_uri {
    'tag:sabayon.org:sark/atom',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless ( $value
        =~ /^([<>]?=)?((?:[A-Za-z0-9+_.-]+\/)?[a-zA-Z0-9+_-]+)?(?:-(\d+(?:\.\d+)*[a-z]*(?:_(?:alpha|beta|pre|p|rc)\d*)?(?:-r\d+)?))?(?::([a-zA-Z0-9._-]+))?(?:\[([^\]]*)\])?(?:#([a-zA-Z0-9._-]+))?(?:::([a-zA-Z0-9\._-]+))?\s*$/
        )
    {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid package atom",
                value   => $value,
            }
        );
    }

    if ( !$value ) {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid package atom",
                value   => $value,
            }
        );
    }

    return 1;
}

1;
