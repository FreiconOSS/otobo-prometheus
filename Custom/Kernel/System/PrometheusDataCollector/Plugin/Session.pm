package Kernel::System::PrometheusDataCollector::Plugin::Session;

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
}

1;
