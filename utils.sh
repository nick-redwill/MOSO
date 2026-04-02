#!/bin/bash

die() {
    echo -e "${ERROR_TEXT}: $1"
    echo "Aborting."
    exit 1
}

guard() {
    "$@" || die "Command failed: $*"
}

warn() {
    echo -e "${WARNING_TEXT}: $1"
}

check_dependencies() {
    local missing=false
    for cmd in dd parted wipefs mkfs.vfat partprobe blockdev; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Required command not found: $cmd"
            missing=true
        fi
    done
    
    $missing && die "Please install missing dependencies"
}

usage() {
    cat << EOF
Usage: moso [OPTIONS] <device>

Options:
  --iso <system:/path>       ISO to install (repeatable)
  --force                    Skip confirmation prompt
  --no-verify                Skip checksum verification
  --help                     Show this help

Examples:
  moso --iso mint:/path/to/mint.iso --iso arch:/path/to/arch.iso /dev/sdb
  moso --iso fedora:/path/to/fedora.iso --force /dev/sdb
EOF
    exit 0
}

confirm_wipe() {
    echo -e "${RED}┌─────────────────────────────────────────┐${RESET}"
    echo -e "${RED}│${BOLD}              W A R N I N G              ${RESET}${RED}│${RESET}"
    echo -e "${RED}└─────────────────────────────────────────┘${RESET}"
    echo ""

    echo -e "  ${YELLOW}Target device:${RESET} $TARGET"
    echo -e "  ${YELLOW}ISOs to write:${RESET}"
    for iso in "${ISOS[@]}"; do
        echo -e "    - ${iso%%:*} -> ${iso##*:}"
    done
    echo ""

    echo -e "  ${RED}${BOLD}ALL DATA ON $TARGET WILL BE DESTROYED${RESET}"
    echo ""

    read -rp "$(echo -e "  ${GREEN}Type YES to continue:${RESET} ")" confirm
    echo ""

    [[ "$confirm" == "YES" ]] || {
        echo -e "${RED}Aborted.${RESET}"
        exit 0
    }
}

wait_for_drive() {
    local drive=$1
    local part=${2:-""}

    # Tell kernel to re-read partition table
    guard sync
    guard partprobe "$drive"

    # Wait for udev to process all events
    guard udevadm settle --timeout=30

    # Wait for specific partition to appear if specified
    if [ -n "$part" ]; then
        local retries=30
        while [ $retries -gt 0 ]; do
            [ -b "$part" ] && break
            sleep 0.5
            retries=$((retries - 1))
        done
        [ -b "$part" ] || die "Partition $part did not appear after 15 seconds"
    fi

    # Flush block device buffers
    guard blockdev --flushbufs "$drive"
}

human_size() {
    local bytes=$1
    if   [ "$bytes" -ge $((1024*1024*1024)) ]; then
        echo "$(( bytes / 1024 / 1024 / 1024 ))GiB"
    elif [ "$bytes" -ge $((1024*1024)) ]; then
        echo "$(( bytes / 1024 / 1024 ))MiB"
    else
        echo "$(( bytes / 1024 ))KiB"
    fi
}

compare_files() {
    local src=$1
    local dst=$2
    local name
    name=$(basename "$src")

    if [ ! -f "$dst" ]; then
        echo "  MISSING: $name"
        return 1
    fi

    local src_sum dst_sum
    src_sum=$(md5sum "$src" | awk '{print $1}')
    dst_sum=$(md5sum "$dst" | awk '{print $1}')

    if [ "$src_sum" = "$dst_sum" ]; then
        echo "  OK: $name"
        return 0
    else
        echo "  MISMATCH: $name"
        echo "    Expected: $src_sum"
        echo "    Got:      $dst_sum"
        return 1
    fi
}
