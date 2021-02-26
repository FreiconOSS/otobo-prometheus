package Kernel::System::Web::MetricInterface;

use strict;
use warnings;
use Net::Prometheus;
use Data::Dumper;

sub new {
    my ($Type, %Param) = @_;
    my $Self = {};
    bless($Self, $Type);
    $Self->{Debug} = $Param{Debug} || 0;
    return $Self;
}

sub Run {
    my $Self = shift;
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $client = Net::Prometheus->new;

    $client->new_counter(
        name   => "perl_info",
        help   => "Information about the perl environment",
        labels => [
            "version",
        ]
    )->labels({ version => $] })->inc;

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
    $client->new_gauge(
        name => "otobo_system_id",
        help => "",
    )->set($Kernel::OM->Get('Kernel::Config')->Get('SystemID'));

    {
        my @List = $Kernel::OM->Get('Kernel::System::Package')->RepositoryList(Result => 'short');
        for (@List) {
            if ($_->{Status} ne 'installed') {
                next;
            }
            $client->new_counter(
                name   => "otobo_package_installed",
                help   => "",
                labels => [
                    "name",
                    "version",
                    "vendor"
                ]
            )->labels({
                version => $_->{Version},
                name    => $_->{Name},
                vendor  => $_->{Vendor},
            })->inc;
        }

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
    {
        $DBObject->Prepare(
            SQL => 'SELECT count(*) FROM mail_queue',
        );

        my $g3 = $client->new_counter(
            name => "otobo_mail_queue_count",
            help => "",
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $g3->inc($Row[0]);
        }
    }
    {
        my $g1 = $client->new_gauge(
            name   => "otobo_sessions_count",
            help   => "",
            labels => [
                "user_type"
            ]
        );
        my $g2 = $client->new_gauge(
            name   => "otobo_sessions_unique_count",
            help   => "",
            labels => [
                "user_type"
            ]
        );
        for my $UserType (qw(User Customer)) {
            my $AuthSessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');
            my %ActiveSessions = $AuthSessionObject->GetActiveSessions(
                UserType => $UserType,
            );

            $g1->labels({ user_type => $UserType })->set($ActiveSessions{Total});
            $g2->labels({ user_type => $UserType })->set(scalar keys %{$ActiveSessions{PerUser}});
        }
    }
    {
        $DBObject->Prepare(
            SQL => 'SELECT communication_channel.name channel, article_sender_type.name sender, a.c
        FROM (
            SELECT communication_channel_id, article_sender_type_id, count(*) c
        FROM article
            GROUP BY communication_channel_id, article_sender_type_id
        ) a
        LEFT JOIN communication_channel ON communication_channel_id = communication_channel.id
            LEFT JOIN article_sender_type ON article_sender_type_id = article_sender_type.id',
        );

        my $g5 = $client->new_counter(
            name   => "otobo_article_count",
            help   => "",
            labels => [
                "channel",
                "sender",
            ]
        );
        while (my @Row = $DBObject->FetchrowArray()) {
            $g5->labels({
                channel => $Row[0],
                sender  => $Row[1],
            })->inc($Row[2]);
        }
    }
    {
        my $SystemMaintenanceObject = $Kernel::OM->Get('Kernel::System::SystemMaintenance');
        my $ActiveMaintenance = $SystemMaintenanceObject->SystemMaintenanceIsActive();
        $client->new_gauge(
            name => "otobo_maintenance_active",
            help => "",
        )->set(($ActiveMaintenance || 0) != 0);
    }
    {
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
    {
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

    {
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

    {
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

    {

        my $DefaultSkin = $Kernel::OM->Get('Kernel::Config')->Get('Loader::Agent::DefaultSelectedSkin');

        $DBObject->Prepare(
            SQL => 'SELECT preferences_value, count(*) c
        FROM user_preferences
            WHERE preferences_key = "UserSkin"
        GROUP BY preferences_value'
        );

        my $gauge = $client->new_gauge(
            name   => "otobo_agent_skin_usage",
            help   => "",
            labels => [
                "skin",
                "default"
            ]
        );

        while (my @Row = $DBObject->FetchrowArray()) {
            $gauge->labels({
                skin    => $Row[0],
                default => $Row[0] eq $DefaultSkin,
            })->set($Row[1]);
        }
    }
    {

        my $DefaultTheme = $Kernel::OM->Get('Kernel::Config')->Get('DefaultTheme');

        $DBObject->Prepare(
            SQL => 'SELECT preferences_value, count(*) c
        FROM user_preferences
            WHERE preferences_key = "UserTheme"
        GROUP BY preferences_value'
        );
        my $g1 = $client->new_gauge(
            name   => "otobo_agent_theme_usage",
            help   => "",
            labels => [
                "theme",
                "default"
            ]
        );

        while (my @Row = $DBObject->FetchrowArray()) {
            $g1->labels({
                theme   => $Row[0],
                default => $Row[0] eq $DefaultTheme,
            })->set($Row[1]);
        }
    }

    # scheduler tasks
    # notification events count
    # Action/Subaction
    # GenericAgent

    $Self->_PrintResponse($client->render);
}

sub _PrintResponse {
    my ($Self, $Data) = @_;
    print STDOUT "Content-Type: text/plain; version=0.0.4\n\n";
    print STDOUT $Data . "\n";
    return 1;
}

1;
