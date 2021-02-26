package Kernel::System::PrometheusDataCollector::Plugin::TimeBetweenFirstAndLastTicket;

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
        SQL => "SELECT max(create_time), min(create_time) FROM ticket WHERE id > 1 ",
    );
    my $TicketWindowTime = 1;
    while (my @Row = $DBObject->FetchrowArray()) {
        if ($Row[0] && $Row[1]) {
            my $OldestCreateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String => $Row[0],
                },
            );
            my $NewestCreateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String => $Row[1],
                },
            );
            my $Delta = $NewestCreateTimeObject->Delta(DateTimeObject => $OldestCreateTimeObject);
            $TicketWindowTime = ($Delta->{AbsoluteSeconds});
        }
    }
    $TicketWindowTime = 1 if $TicketWindowTime < 1;

    $client->new_gauge(
        name => "otobo_seconds_between_first_and_last_ticket",
        help => "",
    )->set($TicketWindowTime);

}

1;
