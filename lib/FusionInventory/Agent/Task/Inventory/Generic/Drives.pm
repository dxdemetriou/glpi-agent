package FusionInventory::Agent::Task::Inventory::Generic::Drives;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use constant    category    => "drive";

sub isEnabled {
    return 1;
}

sub doInventory {}

1;
