package Sark::RxType::Overlay;
use parent 'Data::Rx::CommonType::EasyNew';

sub type_uri {
    'tag:sabayon.org:sark/overlay',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless ( $value =~ /^[a-zA-Z0-9_-]+$/ ) {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid overlay name",
                value   => $value,
            }
        );
    }

    return 1;
}

1;

