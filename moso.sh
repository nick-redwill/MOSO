#!/bin/bash
# MOSO - Multiboot Operating System Orchestrator

# Loading modules
SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/tui.sh"
source "$SCRIPT_DIR/utils.sh"

source "$SCRIPT_DIR/probe.sh"
source "$SCRIPT_DIR/space.sh"
source "$SCRIPT_DIR/partition.sh"
source "$SCRIPT_DIR/grub.sh"
source "$SCRIPT_DIR/iso.sh"

# Constants
BUFFER_SIZE=$((20 * 1024 * 1024))  # Additional 20 MiB buffer in bytes
BOOT_SIZE=$((501 * 1024 * 1024))      # EFI + BOOT partitions size

# Global values
FORCE=false
VERIFY=true
TARGET=""
MOUNT_POINT="/tmp/moso_efi"
GRUB_CMD=""
GRUB_FOLDER=""

declare -a ISOS
declare -a PROBED


# Parsing arguments
[ $# -eq 0 ] && usage


while [[ $# -gt 0 ]]; do
    case "$1" in
        --iso)
            [[ "$2" == *":"* ]] || {
                die "--iso format must be system:/path/to/iso"
            }
            ISOS+=("$2")
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --no-verify)
            VERIFY=false
            shift
            ;;
        --help)
            usage
            ;;
        /dev/*)
            TARGET="$1"
            shift
            ;;
        *)
            die "Unknown argument $1"
            usage
            ;;
    esac
done

# Validating arguments
[ -z "$TARGET" ] && { die "No target device specified"; }
[ ${#ISOS[@]} -eq 0 ] && { die "No ISOs specified"; }
[ -b "$TARGET" ] || { die "$TARGET is not a block device"; }


main() {
    detect_grub

    echo ""
    echo -e "${BRIGHT_WHITE}${BOLD}███╗   ███╗  ██████╗  ███████╗  ██████╗"
    echo -e "${BRIGHT_WHITE}${BOLD}████╗ ████║ ██╔═══██╗ ██╔════╝ ██╔═══██╗"
    echo -e "${BRIGHT_WHITE}${BOLD}██╔████╔██║ ██║   ██║ ███████╗ ██║   ██║"
    echo -e "${BRIGHT_WHITE}${BOLD}██║╚██╔╝██║ ██║   ██║ ╚════██║ ██║   ██║"
    echo -e "${BRIGHT_WHITE}${BOLD}██║ ╚═╝ ██║ ╚██████╔╝ ███████║ ╚██████╔╝"
    echo -e "${BRIGHT_WHITE}${BOLD}╚═╝     ╚═╝  ╚═════╝  ╚══════╝  ╚═════╝${RESET}"

    echo ""
    echo -e "${BOLD}Multiboot Operating System Orchestrator${RESET}"
    echo ""
    echo -e "by ${BLUE}@nick-redwill${RESET}"
    echo "══════════════════════════════════════"
    echo ""

    # Probe system scripts
    echo -e "${BLUE}[ 1/6 ] Probing system scripts...${RESET}"
    probe_all ISOS PROBED || exit 1
    echo ""

    # Check space
    echo -e "${BLUE}[ 2/6 ] Checking space...${RESET}"
    check_space PROBED "$TARGET" || exit 1
    echo ""

    # Confirm wipe
    if [ "$FORCE" = false ]; then
        confirm_wipe
    else
        echo "[ --force ] Skipping confirmation"
        echo ""
    fi

    # Setup drive
    echo -e "${BLUE}[ 3/6 ] Setting up drive...${RESET}"
    setup_drive "$TARGET" PROBED "$MOUNT_POINT" || exit 1
    echo ""

    echo -e "${BLUE}[ 4/6 ] Installing GRUB${RESET}"
    install_grub "$TARGET" "$MOUNT_POINT"
    echo ""

    echo -e "${BLUE}[ 5/6 ] Writing ISOs...${RESET}"
    write_isos "$TARGET" PROBED "$MOUNT_POINT" || exit 1

    echo -e "${BLUE}[ 6/6 ] Cleaning up...${RESET}"
    unmount_drive "$TARGET"
    rmdir $MOUNT_POINT

    sync
    
    echo ""
    echo "══════════════════════════════════════"
    echo -e "${GREEN}Done. Safe to remove $TARGET${RESET}"
}

main