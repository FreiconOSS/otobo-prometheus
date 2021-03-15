package Kernel::System::PrometheusStorage;

use strict;
use warnings;
use Data::Dumper;
use Kernel::System::DateTime;

use Kernel::System::VariableCheck qw(IsArrayRefWithData IsHashRefWithData);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
);



sub new {
    my ($Type, %Param) = @_;

    my $Self = {};
    bless($Self, $Type);

    $Self->{Debug} = 0;
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    $Self->{Config} = {
        Enabled        => $ConfigObject->Get('Prometheus::Storage::Redis')->{Enabled} || 0,
        Address        => $ConfigObject->Get('Prometheus::Storage::Redis')->{Server} || '127.0.0.1:6379',
        DatabaseNumber => $ConfigObject->Get('Prometheus::Storage::Redis')->{DatabaseNumber} || 0,
        RedisFast      => $ConfigObject->Get('Prometheus::Storage::Redis')->{RedisFast} || 1,

    };

    # Not connected yet
    $Self->{Redis} = undef;

    return $Self;
}

sub Incr {
    my ($Self, %Param) = @_;

    for my $Needed (qw(Key Labels)) {
        if (!defined $Param{$Needed}) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # Connect to Redis if not connected
    return if !$Self->{Redis} && !$Self->_Connect();

    my $field = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
        Data => $Param{Labels},
    );
    eval {
        $Self->{Redis}->hincrbyfloat($Param{Key}, $field, 1);
    };
    if ($@) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $@,
        );
        return;
    }

    return 1;
}


sub Get {
    my ($Self, %Param) = @_;

    for my $Needed (qw(Key)) {
        if (!defined $Param{$Needed}) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # Connect to Redis if not connected
    return if !$Self->{Redis} && !$Self->_Connect();

    my %raw;
    eval {
        %raw = $Self->{Redis}->hgetall($Param{Key});
    };
    if ($@) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $@,
        );
        return;
    }

    my @res;
    foreach my $k (keys %raw) {
        my $v = $raw{$k};

        push @res, {
            Key    => $Param{Key},
            Labels => $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                Data => $k,
            ),
            Value  => $v,
        }
    }

    return @res;
}

sub _Connect {
    my $Self = shift;

    if ($Self->{Config}{Enabled}) {
        return;
    }

    return if $Self->{Redis};

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
    my $Loaded = $MainObject->Require(
        $Self->{Config}{RedisFast} ? 'Redis::Fast' : 'Redis',
    );
    return if !$Loaded;

    eval {
        if ($Self->{Config}{RedisFast}) {
            $Self->{Redis} = Redis::Fast->new(server => $Self->{Config}{Address});
        }
        else {
            $Self->{Redis} = Redis->new(server => $Self->{Config}{Address});
        }
        if (
            $Self->{Config}{DatabaseNumber}
                && !$Self->{Redis}->select($Self->{Config}{DatabaseNumber})
        ) {
            die "Can't select database '$Self->{Config}{DatabaseNumber}'!";
        }
    };
    if ($@) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Redis error: $@!",
        );
        $Self->{Redis} = undef;
        return;
    }

    return 1;
}


1;
