package FusionInventory::Agent::Task::Inventory::Generic::Batteries;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use constant    category    => "battery";

sub isEnabled {
    return 1;
}

sub doInventory {}

1;
