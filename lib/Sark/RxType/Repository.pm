package Sark::RxType::Repository;
use parent 'Data::Rx::CommonType::EasyNew';
use Data::Rx::Failure;

sub type_uri {
    'tag:sabayon.org:sark/repository',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless ( $value =~ /^[a-zA-Z0-9_-]+$/ ) {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid repository name",
                value   => $value,
            }
        );
    }

    return 1;
}

1;

