package Kernel::System::PrometheusDataCollector::Plugin::SystemID;

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
    $client->new_gauge(
        name => "otobo_system_id",
        help => "",
    )->set($Kernel::OM->Get('Kernel::Config')->Get('SystemID'));


}

1;
