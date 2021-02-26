package Kernel::System::PrometheusDataCollector::Plugin::Article;

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

}

1;
