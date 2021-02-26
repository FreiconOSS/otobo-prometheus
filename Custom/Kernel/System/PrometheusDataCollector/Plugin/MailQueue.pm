package Kernel::System::PrometheusDataCollector::Plugin::MailQueue;

use strict;
use warnings;

use Net::Prometheus;

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
}

1;
