package Kernel::System::Prometheus;

use strict;
use warnings;

use Kernel::System::DateTime;

use Kernel::System::VariableCheck qw( IsArrayRefWithData IsHashRefWithData );

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = 0;
    $Self->{client} = Net::Prometheus->new;
    return $Self;
}

sub new_gauge {
    my ( $Self, %Param ) = @_;
    return $Self->{client}->new_gauge(%Param);
}

sub new_counter {
    my ( $Self, %Param ) = @_;
    return $Self->{client}->new_counter(%Param);
}

sub render {
    my ( $Self, %Param ) = @_;
    return $Self->{client}->render(%Param);
}

1;
