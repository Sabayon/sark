package Sark::RxType::RemoteOverlay;
use parent 'Data::Rx::CommonType::EasyNew';

sub type_uri {
    'tag:sabayon.org:sark/remote_overlay',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless (
        $value =~ /^[a-zA-Z0-9_-]+\|(git(hub)?|bitbucket|svn|https?)\|.*$/ )
    {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid remote overlay",
                value   => $value,
            }
        );
    }

    return 1;
}

1;
