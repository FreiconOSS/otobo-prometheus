package Kernel::System::PrometheusDataCollector::Plugin::SysConfig;

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



    {
        my %Deployment = $Kernel::OM->Get('Kernel::System::SysConfig::DB')->DeploymentGetLast();
        $client->new_counter(
            name => "otobo_sysconfig_deployment",
            help => "",
        )->inc($Deployment{DeploymentID});
    }
    {

        my $Count;

        $DBObject->Prepare(
            SQL => 'SELECT COUNT(id) FROM sysconfig_default',
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $Count = $Row[0];
        }
        $client->new_gauge(
            name => "otobo_sysconfig_default_count",
            help => "",
        )->inc($Count);
    }
    {
        my $Count;
        $DBObject->Prepare(
            SQL => 'SELECT COUNT(id) FROM sysconfig_modified',
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $Count = $Row[0];
        }
        $client->new_gauge(
            name => "otobo_sysconfig_modified_count",
            help => "",
        )->inc($Count);
    }
}

1;
