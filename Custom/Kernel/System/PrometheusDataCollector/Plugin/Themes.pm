package Kernel::System::PrometheusDataCollector::Plugin::Themes;

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

1;
