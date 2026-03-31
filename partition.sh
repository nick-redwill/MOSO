#!/bin/bash

unmount_drive() {
    local drive=$1
    echo "Unmounting all partitions on $drive..."
    mount | grep "^$drive" | awk '{print $1}' | while read -r part; do
        guard umount "$part"
        echo "  Unmounted $part"
    done
}

get_partition() {
    local drive=$1
    local num=$2
    if [[ "$drive" == *"nvme"* ]]; then
        echo "${drive}p${num}"
    else
        echo "${drive}${num}"
    fi
}

wipe_drive() {
    local drive=$1
    echo "Wiping existing partition table on $drive..."
    guard wipefs -a "$drive"

    wait_for_drive "$drive"
}

create_base_partitions() {
    local drive=$1
    
    # Initialize the disk with a GPT label
    guard parted -s "$drive" \
        mklabel gpt \
        mkpart "BIOS-BOOT" 1MiB 2MiB \
        set 1 bios_grub on \
        mkpart "ESP" fat32 2MiB 500MiB \
        set 2 esp on
}

partition_drive() {
    local drive=$1
    local -n _probed=$2

    echo "Partitioning $drive"

    # 1. Wipe and create GPT label immediately
    guard parted -s "$drive" mklabel gpt

    # 2. Creating base partition
    create_base_partitions "$drive"
    wait_for_drive "$drive" "$(get_partition $drive 2)"

    # 3. Track where the next partition starts
    local current_offset
    current_offset=$(guard parted -s "$drive" unit MiB print | awk '/^ / {last=$3} END {print last}' | sed 's/MiB//')

    # If the disk was empty/failed to read, default to 1
    [[ -z "$current_offset" ]] && current_offset=1

    # 4. Loop through systems
    for entry in "${_probed[@]}"; do
        local system="${entry%%:*}"
        local path="${entry#*:}"
        path="${path%%:*}"
        local script="${entry##*:}"

        echo "Processing $system from $script..."

        # Source system script
        source "$script"

        # Instead of returning a string, make_partition now executes 
        # and returns the NEW end offset of the disk.
        # We pass: drive, system_name, iso_path, and current_offset
        current_offset=$(make_partition "$drive" "$system" "$path" "$current_offset")
        wait_for_drive "$drive" "$(get_partition $drive $part_num)"

        # echo "Current disk offset: ${current_offset}MiB"
    done

    echo "Partitioning complete."
}

format_efi() {
    local drive=$1
    local efi_part
    efi_part=$(get_partition "$drive" 2)

    echo "Formatting EFI partition..."
    guard mkfs.vfat -F32 -n BOOT "$efi_part"
}

setup_drive() {
    local drive=$1
    local -n _setup_probed=$2
    local mount_point=$3

    unmount_drive "$drive"
    wipe_drive "$drive"
    partition_drive "$drive" _setup_probed
    format_efi "$drive"
}