package Kernel::System::PrometheusDataCollector::Plugin::Packages;

use strict;
use warnings;

use Net::Prometheus;
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {%Param};
    bless( $Self, $Type );
    return $Self;
}

sub Run {
    my $Self = shift;
    my $client = $Kernel::OM->Get('Kernel::System::Prometheus');
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
}

1;
