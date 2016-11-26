package Sark::RxType::Boolean;
use parent 'Data::Rx::CommonType::EasyNew';
use Data::Rx::Failure;

sub type_uri {
    'tag:sabayon.org:sark/bool',;
}

sub assert_valid {
    my ( $self, $value ) = @_;

    unless ( $value
        =~ /^y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF|$/
        )
    {
        $self->fail(
            {   error   => [qw(type)],
                message => "Invalid boolean value",
                value   => $value,
            }
        );
    }

    return 1;
}

1;
