#!/bin/bash
# scripts/linux/fedora.sh

source "$(dirname "${BASH_SOURCE[0]}")/linux.sh"

SYSTEM_NAME="Fedora"

# Overriding grub_entry function
grub_entry() {
    local uuid=$1
    local part=$2

    cat << EOF

menuentry "$SYSTEM_NAME ($part)" {
    search --no-floppy --set=root --fs-uuid $uuid
    configfile /boot/grub2/grub.cfg
}
EOF
}