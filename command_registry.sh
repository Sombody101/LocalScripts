#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

register_module() {
    core::hide_trace
    local export_mod module_name cmds

    [[ "$1" == export ]] && {
        export_mod=true
    }

    while [[ "$*" ]]; do
        module_name="$1"

        [[ ! "$module_name" ]] && {
            warn "No module names given"
            return 1
        }

        cmds=()

        while IFS= read -r cmd; do
            [[ $cmd =~ ^$module_name ]] && cmds+=("$cmd")
            [[ "$export_mod" ]] && export -f "${cmd?}"
        done < <(declare -F | cut -d ' ' -f 3 | grep -E ^"$module_name\.|$module_name::")

        [[ "${#cmds[@]}" -eq 0 ]] && {
            warn "Failed to find any defined commands for module '$module_name'"
            return 1
        }

        __REGISTERED_COMMANDS+=("${cmds[@]}")

        : "${CYAN}MODULE REGISTERED: ${module_name}${NORM}"

        shift
    done
}

cmds() {
    local module_name

    module_name="$1"

    [[ ! "$module_name" ]] && {
        array __REGISTERED_COMMANDS
        return
    }

    while IFS= read -r cmd; do
        [[ $cmd =~ ^$module_name. ]] && echo "$cmd"
    done < <(array __REGISTERED_COMMANDS)
}

chelp() {
    [[ "$1" == "--help" ]] && {
        shift
        echo "$@"
        return 1
    }

    : "${CYAN}HELP INFORMATION${NORM}"
    : "$1"
}
