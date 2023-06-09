#!/usr/bin/env perl

use strict;
use warnings;

# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/cpan-lib";
use lib "$Bin/../../Custom";

use Kernel::System::Web::InterfaceMetric;
use Kernel::System::ObjectManager;

local $Kernel::OM = Kernel::System::ObjectManager->new();

my $Interface = Kernel::System::Web::InterfaceMetric->new(Debug => 0);
$Interface->Run();
