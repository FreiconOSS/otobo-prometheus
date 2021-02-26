package Kernel::System::PrometheusDataCollector::Plugin::CommunicationStats;

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

    $DBObject->Prepare(SQL => 'SELECT direction, status, count(*) c FROM communication_log GROUP BY direction, status');
    my $g7 = $client->new_gauge(
        name   => "otobo_communication_stats",
        help   => "",
        labels => [
            "direction",
            "status",
        ]
    );
    while (my @Row = $DBObject->FetchrowArray()) {
        $g7->labels({
            direction => $Row[0],
            status    => $Row[1],
        })->inc($Row[2]);
    }
}

1;
