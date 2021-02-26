package Kernel::System::PrometheusDataCollector::Plugin::TicketsWithInvalidUser;

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

    my $InvalidUsersTicketCount;
    $DBObject->Prepare(
        SQL   => '
        SELECT COUNT(*) FROM ticket, users
        WHERE
            ticket.user_id = users.id
            AND ticket.ticket_lock_id = 2
            AND users.valid_id != 1
        ',
        Limit => 1,
    );

    while (my @Row = $DBObject->FetchrowArray()) {
        $InvalidUsersTicketCount = $Row[0];
    }
    $client->new_gauge(
        name => "otobo_locked_ticked_with_invalid_user",
        help => "",
    )->set($InvalidUsersTicketCount);
}

1;
