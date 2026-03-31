#!/bin/bash

detect_grub() {
    if command -v grub2-install &>/dev/null; then
        GRUB_CMD="grub2-install"
        GRUB_FOLDER="boot/grub2"

    elif command -v grub-install &>/dev/null; then
        GRUB_CMD="grub-install"
        GRUB_FOLDER="boot/grub"
    else
        die "Neither grub-install nor grub2-install found"
    fi
}

install_grub() {
    local drive=$1
    local mount_point=$2

    guard mkdir -p "$mount_point"
    guard mount "$(get_partition $drive 2)" "$mount_point"

    echo "Installing GRUB EFI using $GRUB_CMD..."
    guard "$GRUB_CMD" \
        --target=x86_64-efi \
        --efi-directory="$mount_point" \
        --boot-directory="$mount_point/boot" \
        --removable --force

    echo "Installing GRUB BIOS using $GRUB_CMD..."
    guard "$GRUB_CMD" \
        --target=i386-pc \
        --boot-directory="$mount_point/boot" \
        $drive

    echo "GRUB installed successfully"
}

write_grub_header() {
    local mount_point=$1

    cat << EOF > "$mount_point/$GRUB_FOLDER/grub.cfg"
insmod iso9660
insmod part_gpt

set default=0
set timeout=30

EOF
}