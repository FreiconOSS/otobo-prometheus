package Kernel::System::PrometheusDataCollector::Plugin::DatabaseRecords;

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

    my $g7 = $client->new_gauge(
        name   => "otobo_database_record_count",
        help   => "",
        labels => [
            "type",
        ]
    );

    my @Checks = (
        {
            SQL        => "SELECT count(*) FROM ticket",
            Identifier => 'TicketCount',
        },
        {
            SQL        => "SELECT count(*) FROM ticket_history",
            Identifier => 'TicketHistoryCount',
        },
        {
            SQL        => "SELECT count(*) FROM article",
            Identifier => 'ArticleCount',
        },
        {
            SQL        =>
                "SELECT count(*) from article_data_mime_attachment WHERE content_type NOT LIKE 'text/html%'",
            Identifier => 'AttachmentCountDBNonHTML',
        },
        {
            SQL        => "SELECT count(DISTINCT(customer_user_id)) FROM ticket",
            Identifier => 'DistinctTicketCustomerCount',
        },
        {
            SQL        => "SELECT count(*) FROM queue",
            Identifier => 'QueueCount',
        },
        {
            SQL        => "SELECT count(*) FROM service",
            Identifier => 'ServiceCount',
        },
        {
            SQL        => "SELECT count(*) FROM users",
            Identifier => 'AgentCount',
        },
        {
            SQL        => "SELECT count(*) FROM roles",
            Identifier => 'RoleCount',
        },
        {
            SQL        => "SELECT count(*) FROM groups_table",
            Identifier => 'GroupCount',
        },
        {
            SQL        => "SELECT count(*) FROM dynamic_field",
            Identifier => 'DynamicFieldCount',
        },
        {
            SQL        => "SELECT count(*) FROM dynamic_field_value",
            Identifier => 'DynamicFieldValueCount',
        },
        {
            SQL        => "SELECT count(*) FROM dynamic_field WHERE valid_id > 1",
            Identifier => 'InvalidDynamicFieldCount',
        },
        {
            SQL        => "
                SELECT count(*)
                FROM dynamic_field_value
                    JOIN dynamic_field ON dynamic_field.id = dynamic_field_value.field_id
                WHERE dynamic_field.valid_id > 1",
            Identifier => 'InvalidDynamicFieldValueCount',
        },
        {
            SQL        => "SELECT count(*) FROM gi_webservice_config",
            Identifier => 'WebserviceCount',
        },
        {
            SQL        => "SELECT count(*) FROM pm_process",
            Identifier => 'ProcessCount',
        },
        {
            SQL        => "
                SELECT count(*)
                FROM dynamic_field df
                    LEFT JOIN dynamic_field_value dfv ON df.id = dfv.field_id
                    RIGHT JOIN ticket t ON t.id = dfv.object_id
                WHERE df.name = '"
                . $Kernel::OM->Get('Kernel::Config')->Get("Process::DynamicFieldProcessManagementProcessID") . "'",
            Identifier => 'ProcessTickets',
        },
    );

    my %Counts;

    for my $Check (@Checks) {
        $DBObject->Prepare(SQL => $Check->{SQL});
        while (my @Row = $DBObject->FetchrowArray()) {
            $Counts{ $Check->{Identifier} } = $Row[0];
        }

        if (defined $Counts{ $Check->{Identifier} }) {
            $g7->labels({
                type => $Check->{Identifier},
            })->inc($Counts{ $Check->{Identifier} });
        }
        else {
            $g7->labels({
                type => $Check->{Identifier},
            })->inc(0);
        }
    }

}

1;
