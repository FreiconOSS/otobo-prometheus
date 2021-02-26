package Kernel::System::Web::InterfaceMetric;

use strict;
use warnings;
use Net::Prometheus;
use Data::Dumper;
use Time::HiRes;

sub new {
    my ($Type, %Param) = @_;
    my $Self = {};
    bless($Self, $Type);
    $Self->{Debug} = $Param{Debug} || 0;
    return $Self;
}

sub Run {
    my $Self = shift;
    my $client = $Kernel::OM->Get('Kernel::System::Prometheus');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');


    my $Plugins = $ConfigObject->Get("Prometheus::Plugin");

    my $pluginTook = $client->new_gauge(
        name   => "otobo_prometheus_plugin_execute_took_seconds",
        help   => "",
        labels => [
            "name"
        ]
    );
    for (keys %{$Plugins}) {
        my $class = $Plugins->{$_}->{Module};

        eval "require $class" or do { die "can't load $class: $@" };
        my $PluginObject = ($class)->new();
        my $start = [Time::HiRes::gettimeofday()];
        $PluginObject->Run();

        $pluginTook->labels({
            name => $_,
        })->set(Time::HiRes::tv_interval($start));
    }

    $Self->_PrintResponse($client->render);
}

sub _PrintResponse {
    my ($Self, $Data) = @_;
    print STDOUT "Content-Type: text/plain; version=0.0.4\n\n";
    print STDOUT $Data . "\n";
    return 1;
}

1;
