#!/bin/bash

SYSTEM_NAME="" # System name (for GRUB entry)

# Function that returns required size for specific systems partition
# Arguments:
#   $1 - iso (path to iso file)
get_required_size() {}


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
#NOTE: This function is called inside the setup()
grub_entry() {}