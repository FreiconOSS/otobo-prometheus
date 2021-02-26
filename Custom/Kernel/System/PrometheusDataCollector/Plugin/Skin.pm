package Kernel::System::PrometheusDataCollector::Plugin::Skin;

use strict;
use warnings;

sub new {
    my ($Type, %Param) = @_;
    my $Self = { %Param };
    bless($Self, $Type);
    return $Self;
}

sub Run() {
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $client = $Kernel::OM->Get('Kernel::System::Prometheus');

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
