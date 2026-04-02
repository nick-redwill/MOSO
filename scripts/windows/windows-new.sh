#!/bin/bash

get_required_size() {
    local iso=$1

    # ISO size + extra 100MiB
    local iso_size_bytes
    iso_size_bytes=$(( $(guard stat -c%s "$iso") + 100 * 1024 * 1024 ))

    echo "$iso_size_bytes"
}

make_partition() {
    local drive=$1
    local part=$2
    local iso=$3
    local start_mib=$4

    local iso_size_bytes
    iso_size_bytes=$(get_required_size "$iso")

    # Windows needs extra space for extraction overhead
    local size_mib=$(( (iso_size_bytes + BUFFER_SIZE) / 1024 / 1024 ))
    local end_mib=$(( start_mib + size_mib ))

    guard parted -s "$drive" mkpart "$part" ntfs "${start_mib}MiB" "${end_mib}MiB" > /dev/null

    echo "$end_mib"
}

_verify_windows() {
    local tmp_iso=$1
    local tmp_part=$2
    local failed=false

    echo "  Verifying critical files..."

    # Critical boot files
    local critical_files=(
        "efi/boot/bootx64.efi"
        "bootmgr"
        "boot/bcd"
        "boot/boot.sdi"
        "sources/install.wim"
        "sources/boot.wim"
    )

    # Checking critical boot files
    for f in "${critical_files[@]}"; do
        if [ -f "$tmp_iso/$f" ]; then
            compare_files "$tmp_iso/$f" "$tmp_part/$f" || failed=true
        fi
    done

    # Comparing file counts
    local iso_count part_count
    iso_count=$(find "$tmp_iso" -type f | wc -l)
    part_count=$(find "$tmp_part" -type f | wc -l)

    if [ "$iso_count" != "$part_count" ]; then
        echo "  File count mismatch: ISO=$iso_count PART=$part_count"
        failed=true
    else
        echo "  File count OK: $iso_count files"
    fi

    $failed && return 1 || echo "  Verification OK"
}


setup() {
    local part=$1
    local iso=$2
    local efi_mount=$3

    # Formatting as NTFS
    echo "  Formatting $part as NTFS..."
    guard mkfs.ntfs -f "$part"
    wait_for_drive "$drive"

    local tmp_iso=$(mktemp -d)
    local tmp_part=$(mktemp -d)

    guard mount -o loop "$iso" "$tmp_iso"
    guard mount "$part" "$tmp_part"

    # Using rsync if available, otherwise falling back to cp
    #TODO: Make rsync less verbose
    echo "  Extracting $SYSTEM_NAME..."
    if command -v rsync &>/dev/null; then
        guard rsync -achWP "$tmp_iso/" "$tmp_part/"
    else
        guard cp -rT "$tmp_iso" "$tmp_part"
    fi

    wait_for_drive "$drive"

    if [ "$VERIFY" = true ]; then
        _verify_windows "$tmp_iso" "$tmp_part" || {
            guard umount "$tmp_iso"
            guard umount "$tmp_part"
            rm -rf "$tmp_iso" "$tmp_part"
            die "Extraction verification failed for $SYSTEM_NAME"
        }
    fi

    guard umount "$tmp_iso"
    guard umount "$tmp_part"
    rm -rf "$tmp_iso" "$tmp_part"

    local uuid
    uuid=$(blkid -s UUID -o value "$part") || die "Failed to get UUID for $part"

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
    insmod chain
    insmod ntfs

    search --no-floppy --set=root --fs-uuid $uuid
    chainloader (\$root)/efi/boot/bootx64.efi
}
EOF
}
