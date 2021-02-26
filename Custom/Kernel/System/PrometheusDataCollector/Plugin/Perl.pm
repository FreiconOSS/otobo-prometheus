package Kernel::System::PrometheusDataCollector::Plugin::Perl;

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

    $client->new_counter(
        name   => "perl_info",
        help   => "Information about the perl environment",
        labels => [
            "version",
        ]
    )->labels({ version => $] })->inc;
}

1;
