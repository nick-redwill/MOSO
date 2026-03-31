#!/bin/bash

get_drive_size() {
    local drive=$1
    blockdev --getsize64 "$drive"
}

calculate_required() {
    local -n _probed=$1
    local total=0

    for entry in "${_probed[@]}"; do
        local path="${entry#*:}"
        path="${path%%:*}"

        local script="${entry##*:}"
        source "$script"

        local size
        size=$(get_required_size "$path")
        total=$((total + size + BUFFER_PER_ISO))
    done
    total=$((total + $BOOT_SIZE))

    echo "$total"
}

check_space() {
    local -n _check_probed=$1
    local drive=$2

    local required
    local available
    
    required=$(calculate_required _check_probed)
    available=$(get_drive_size "$drive")

    echo "Space check:"
    echo "  Drive size:  $(human_size $available)"
    echo "  Required:    $(human_size $required)"
    echo "  Free after:  $(human_size $((available - required)))"

    if [ "$required" -gt "$available" ]; then
        echo ""
        echo "Error: Not enough space on $drive"
        echo "       Need $(human_size $required), have $(human_size $available)"
        return 1
    fi

    echo "  Status:      OK"
    return 0
}