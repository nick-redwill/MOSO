#!/bin/bash
# scripts/linux/puppy.sh

source "$(dirname "${BASH_SOURCE[0]}")/linux.sh"

SYSTEM_NAME="Puppy"

# Overriding grub_entry function
grub_entry() {
    local uuid=$1
    cat << EOF

menuentry "$SYSTEM_NAME ($part)" {
    search --no-floppy --set=root --fs-uuid $uuid
    configfile /grub.cfg
}
EOF
}