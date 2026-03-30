#!/bin/bash

SYSTEM_NAME="" # System name (for GRUB entry)


# Function for preparing the partition
# Arguments:
#   $1 - drive (e.g. /dev/sdb)
#   $2 - part (e.g. /dev/sdb3)
#   $3 - iso (path to iso file)
#   $4 - start_mib (offset for partition)
make_partition() {}


# Function setting up the system on partition (writing, veryfication and grub configuration)
# Arguments:
#   $1 - part (e.g. /dev/sdb3)
#   $2 - iso (path to iso file)
#   $3 - efi_mount (mount point of EFI partition)
setup() {}


# Function that returns grub menuentry value for the given system
# Arguments:
#   $1 - uuid (partition uuid)
#   $2 - part (e.g. /dev/sdb3)
grub_entry() {}