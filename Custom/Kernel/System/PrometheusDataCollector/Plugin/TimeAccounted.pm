package Kernel::System::PrometheusDataCollector::Plugin::TimeAccounted;

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

    $DBObject->Prepare(
        SQL => 'SELECT SUM(time_unit) FROM time_accounting',
    );
    my $g6 = $client->new_counter(
        name => "otobo_time_accounted_total",
        help => "",
    );
    while (my @Row = $DBObject->FetchrowArray()) {
        $g6->inc($Row[0]);
    }
}

1;
