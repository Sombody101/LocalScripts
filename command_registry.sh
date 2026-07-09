#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

alias register_module='core::obsolete register_module regmod; regmod'

regmod() {
    core::hide_trace
    local export_mod module_name cmds

    [[ "$1" == export ]] && {
        export_mod=true
        shift
    }

    while [[ "$*" ]]; do
        module_name="$1"

        [[ ! "$module_name" ]] && {
            core::error "No module names given"
            return
        }

        cmds=()

        while IFS= read -r cmd; do
            [[ $cmd =~ ^$module_name ]] && cmds+=("$cmd")
            [[ "$export_mod" ]] && export -f "${cmd?}"
        done < <(declare -F | cut -d ' ' -f 3 | grep -E ^"$module_name\.|$module_name::")

        [[ "${#cmds[@]}" -eq 0 ]] && {
            core::error "Failed to find any defined commands for module '$module_name'"
            return
        }

        __REGISTERED_COMMANDS+=("${cmds[@]}")

        core::verbose "[cyan]MODULE REGISTERED: ${module_name}[/]"

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
