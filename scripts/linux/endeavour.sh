#!/bin/bash
# scripts/linux/endeavour.sh

source "$(dirname "${BASH_SOURCE[0]}")/linux.sh"

SYSTEM_NAME="EndeavourOS"

# Overriding grub_entry function
# NOTE: 
# EndeavourOS doesnt use GRUB at all 
# so the best option here is directly booting the kernel 
# using same parameters as their loader
grub_entry() {
    local uuid=$1
    local part=$2

    cat << EOF
### EndeavourOS Open Source (All GPUs)
menuentry '$SYSTEM_NAME with open source drivers: All GPUs ($part)' {
    search --no-floppy --set=root --fs-uuid $uuid
    linux   /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisosearchuuid=$uuid cow_spacesize=10G copytoram=n module_blacklist=pcspkr,nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm nouveau.modeset=1 i915.modeset=1 radeon.modeset=1 nvme_load=yes
    initrd  /arch/boot/x86_64/initramfs-linux.img
}

### EndeavourOS NVIDIA (RTX/Turing+)
menuentry '$SYSTEM_NAME with NVIDIA drivers: Only RTX GPUs, Turing, or later ($part)' {
    search --no-floppy --set=root --fs-uuid $uuid
    linux   /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisosearchuuid=$uuid cow_spacesize=10G copytoram=n module_blacklist=pcspkr,nouveau,nouveau_drm nouveau.modeset=0 nvidia_drm.modeset=1 i915.modeset=1 radeon.modeset=1 nvme_load=yes
    initrd  /arch/boot/x86_64/initramfs-linux.img
}
EOF
}

