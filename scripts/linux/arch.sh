#!/bin/bash
# scripts/linux/arch.sh

source "$(dirname "${BASH_SOURCE[0]}")/linux.sh"

SYSTEM_NAME="Arch"

# Overriding grub_entry function
grub_entry() {
    local uuid=$1
    cat << EOF

menuentry "$SYSTEM_NAME ($part)" {
    search --no-floppy --set=root --fs-uuid $uuid
    configfile /boot/grub/loopback.cfg
}
EOF
}