package Kernel::System::PrometheusDataCollector::Plugin::Maintenance;

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

    my $SystemMaintenanceObject = $Kernel::OM->Get('Kernel::System::SystemMaintenance');
    my $ActiveMaintenance = $SystemMaintenanceObject->SystemMaintenanceIsActive();
    $client->new_gauge(
        name => "otobo_maintenance_active",
        help => "",
    )->set(($ActiveMaintenance || 0) != 0);

}

1;
