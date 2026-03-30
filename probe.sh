#!/bin/bash

SCRIPTS_DIR="$(dirname "$0")/scripts"

probe_system() {
    local system="$1"
    local found=""

    # Search all subdirectories for matching script
    while IFS= read -r script; do
        local basename="${script##*/}" # getting filename
        local name="${basename%.sh}" # removing .sh

        if [[ "${name,,}" == "${system,,}" ]]; then  # case insensitive match
            found="$script"
            break
        fi
    
    done < <(find "$SCRIPTS_DIR" -name "*.sh" -not -name "_template.sh")
    echo "$found"
}

probe_all() {
    local -n isos=$1 # reference to ISOS array
    local -n results=$2 # reference to results array
    local failed=false

    for iso in "${isos[@]}"; do
        local system="${iso%%:*}"
        local path="${iso##*:}"

        # Check ISO file exists
        if [ ! -f "$path" ]; then
            die "ISO file not found: $path"
        fi

        # Find matching script
        local script
        script=$(probe_system "$system")

        if [ -z "$script" ]; then
            echo -e "${ERROR_TEXT}: No script found for system: $system"
            echo "       Available systems:"
            find "$SCRIPTS_DIR" -name "*.sh" \
                -not -name "_template.sh" \
                -printf "         %f\n" | sed 's/.sh//'
            failed=true
            continue
        fi

        echo "  Matched: $system -> $script"
        results+=("$system:$path:$script")
    done

    $failed && return 1 || return 0
}