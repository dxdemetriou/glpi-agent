package FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Adaptec;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return -r '/proc/scsi/scsi';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @devices = getDevicesFromUdev(logger => $logger);

    foreach my $device (@devices) {
        next unless $device->{MANUFACTURER};
        next unless
            $device->{MANUFACTURER} eq 'Adaptec' ||
            $device->{MANUFACTURER} eq 'ServeRA';

        foreach my $disk (_getDisksFromProc(
                controller => 'scsi' . $device->{SCSI_COID},
                name       => $device->{NAME},
                logger     => $logger
            )) {
            $disk->{SERIALNUMBER} = getSerialnumber($disk->{device});
            $inventory->addEntry(section => 'STORAGES', entry => $disk);
        }
    }
}

sub _getDisksFromProc {
    my (%params) = (
        file => '/proc/scsi/scsi',
        @_
    );

    return unless $params{controller};

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @disks;
    my $disk;

    my $count = -1;
    while (my $line = <$handle>) {
        if ($line =~ /^Host: (\w+)/) {
            $count++;
            if ($1 eq $params{controller}) {
                # that's the controller we're looking for
                $disk = {
                    NAME        => $params{name},
                    DESCRIPTION => 'SATA',
                    TYPE        => 'disk',
                };
            } else {
                # that's another controller
                undef $disk;
            }
        }

        if ($line =~ /Model:\s(\S+).*Rev:\s(\S+)/) {
            next unless $disk;
            $disk->{MODEL}    = $1;
            $disk->{FIRMWARE} = $2;

            # that's the controller itself, not a disk
            next if $disk->{MODEL} =~ /(raid|RAID)/;

            $disk->{MANUFACTURER} = getCanonicalManufacturer(
                $disk->{MODEL}
            );
            $disk->{DEVICE} = "/dev/sg$count";

            push @disks, $disk;
        }
    }
    close $handle;

    return @disks;
}

1;
