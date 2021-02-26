package Kernel::System::PrometheusDataCollector::Plugin::TicketStats;

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
        $DBObject->Prepare(
            SQL => 'SELECT
        queue.name           as queue,
        ticket_type.name     as ticket_type,
        service.name         as service,
        ticket_priority.name as ticket_priority,
        ticket_state.name    as ticket_state,
        a.c
        FROM (
            SELECT
                queue_id,
                type_id,
                service_id,
                ticket_priority_id,
                ticket_state_id,
                count(*) as c
            FROM ticket
            GROUP BY queue_id, type_id, service_id, ticket_priority_id, ticket_state_id
        ) as a
        LEFT JOIN queue ON queue_id = queue.id
        LEFT JOIN service ON service_id = service.id
        LEFT JOIN ticket_type ON ticket_state_id = ticket_type.id
        LEFT JOIN ticket_priority ON ticket_state_id = ticket_priority.id
        LEFT JOIN ticket_state ON ticket_state_id = ticket_state.id;',
        );
        my $g = $client->new_gauge(
            name   => "otobo_ticket_count",
            help   => "",
            labels => [
                "queue",
                "ticket_type",
                "service",
                "ticket_priority",
                "ticket_state"
            ]
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $g->labels({
                "queue"           => $Row[0] || "null",
                "ticket_type"     => $Row[1] || "null",
                "service"         => $Row[2] || "null",
                "ticket_priority" => $Row[3] || "null",
                "ticket_state"    => $Row[4] || "null",
            })->inc($Row[5]);
        }
    }


    {
        $DBObject->Prepare(
            SQL => 'SELECT name, a.c
            FROM (
                SELECT ticket_history.history_type_id, count(*) c
                FROM ticket_history
                GROUP BY ticket_history.history_type_id
            ) a
            INNER JOIN ticket_history_type ON id = a.history_type_id',
        );

        my $g2 = $client->new_counter(
            name   => "otobo_ticket_history_count",
            help   => "",
            labels => [
                "type",
            ]
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $g2->labels({
                "type" => $Row[0] || "null",
            })->inc($Row[1]);
        }
    }
}

1;
