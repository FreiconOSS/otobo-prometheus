package Kernel::System::PrometheusDataCollector::Plugin::OTOBO;

use strict;
use warnings;


sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {%Param};
    bless( $Self, $Type );
    return $Self;
}

sub Run {
    my $Self = shift;
    my $client = $Kernel::OM->Get('Kernel::System::Prometheus');
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    $client->new_counter(
        name   => "otobo_info",
        help   => "Information about the otobo environment",
        labels => [
            "version",
            "lang",
            "tz",
            "org"
        ]
    )->labels({
        version => $Kernel::OM->Get('Kernel::Config')->Get('Version'),
        org     => $Kernel::OM->Get('Kernel::Config')->Get('Organization'),
        lang    => $Kernel::OM->Get('Kernel::Config')->Get('DefaultLanguage'),
        tz      => Kernel::System::DateTime->OTOBOTimeZoneGet(),
    })->inc;

}

1;
