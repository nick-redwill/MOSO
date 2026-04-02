#!/bin/bash
# scripts/other/solaris-11.sh

SYSTEM_NAME="Solaris 11"

get_required_size() {
    local iso=$1

    # Simply returning the size of ISO
    local iso_size_bytes
    iso_size_bytes=$(guard stat -c%s "$iso")

    echo "$iso_size_bytes"
}

make_partition() {
    local drive=$1
    local part=$2
    local iso=$3
    local start_mib=$4

    # Calculating partition size + extra buffer
    local iso_size_bytes
    iso_size_bytes=$(get_required_size "$iso")

    local size_mib=$(( (iso_size_bytes + BUFFER_SIZE) / 1024 / 1024 ))
    local end_mib=$(( start_mib + size_mib ))

    # Using 'ext4' as a placeholder
    # parted just needs a hint.
    guard parted -s "$drive" mkpart "$part" ext4 "${start_mib}MiB" "${end_mib}MiB" > /dev/null

    # Echo the NEW offset so the main loop can capture it
    # This becomes the 'start_mib' for the next partition.
    echo "$end_mib"
}

setup() {
    local part=$1
    local iso=$2
    local efi_mount=$3

    # Writing ISO to partition
    echo "  Writing $SYSTEM_NAME to $part..."
    guard dd if="$iso" \
        of="$part" \
        bs=4M \
        status=progress \
        oflag=direct \
        conv=fdatasync

    # Flushing everything after write
    wait_for_drive "$drive"

    if [ "$VERIFY" = true ]; then
        verify_write "$iso" "$part" || die "Write verification failed! Try to write again"
    else
        echo "Skipping verification..."
    fi

    # Fetching UUID for newly written partition
    local uuid
    uuid=$(blkid -s UUID -o value "$part") || die "Failed to get UUID for $part"

    # Writing grub entry
    echo "  Writing grub entry for $SYSTEM_NAME..."
    
    warn "$SYSTEM_NAME only supports UEFI mode"
    grub_entry "$uuid" "$part" >> "$efi_mount/$GRUB_FOLDER/grub.cfg"

    echo "  Done: $SYSTEM_NAME"
}

grub_entry() {
    local uuid=$1
    local part=$2

    cat << EOF

menuentry "$SYSTEM_NAME EFI ($part)" {
    search --no-floppy --set=root --fs-uuid $uuid
    chainloader /boot/grub/grub2oddx64.efi
}
EOF
}