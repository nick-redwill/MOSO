#!/bin/bash

verify_write() {
    local iso=$1
    local part=$2
    local skip_bytes=${3:-0} # Some isos might require skipping some bytes
    local byte_count=${4:-0}

    local iso_size
    iso_size=$(stat -c%s "$iso")
    [ "$byte_count" -eq 0 ] && byte_count=$iso_size

    echo "  Verifying $byte_count bytes..."

    local iso_sum part_sum

    iso_sum=$(dd if="$iso" bs=4M \
        iflag=fullblock,count_bytes \
        skip=$((skip_bytes)) \
        count="$byte_count" \
        2>/dev/null | md5sum | awk '{print $1}')

    part_sum=$(dd if="$part" bs=4M \
        iflag=direct,fullblock,count_bytes \
        count="$byte_count" \
        2>/dev/null | md5sum | awk '{print $1}')

    echo "    Expected: $iso_sum"
    echo "    Got:      $part_sum"

    [ "$iso_sum" = "$part_sum" ] && echo "  OK" || {
        echo "  MISMATCH"
        echo "    Expected: $iso_sum"
        echo "    Got:      $part_sum"
        return 1
    }
}

write_isos() {
    local drive=$1
    local -n _write_probed=$2
    local efi_mount=$3
    
    local part_num=3 # First two are BIOS/EFI partitions

    write_grub_header $efi_mount

    for entry in "${_write_probed[@]}"; do
        local system="${entry%%:*}"
        local path="${entry#*:}"
        path="${path%%:*}"
        local script="${entry##*:}"
        local part
        
        part=$(get_partition "$drive" "$part_num")
        
        # Source system script and call setup
        source "$script"
        setup "$part" "$path" "$efi_mount" || die "Setup failed for $system"

        part_num=$((part_num + 1))

    done
}