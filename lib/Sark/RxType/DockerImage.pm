package Sark::RxType::DockerImage;
use parent 'Data::Rx::CommonType::EasyNew';

sub type_uri {
    'tag:sabayon.org:sark/docker_image',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless ( $value
        =~ /^(?:[a-zA-Z0-9_-]+\/)(?:[a-zA-Z0-9_-]+)(?::[a-zA-Z0-9_-]+)?$/ )
    {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid docker image name",
                value   => $value,
            }
        );
    }

    return 1;
}

1;
