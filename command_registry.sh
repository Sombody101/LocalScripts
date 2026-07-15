#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

alias register_module='core::obsolete register_module regmod; regmod'

leg_regmod() {
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
            [[ $cmd == $module_name* ]] && cmds+=("$cmd")
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

regmod() {
    core::hide_trace
    local export_mod=false module_name fn match_found

    [[ "$1" == export ]] && {
        export_mod=true
        shift
    }

    local all_funcs=()
    readarray -t all_funcs < <(compgen -A function) 2>/dev/null || {
        local line
        while read -r line; do all_funcs+=("$line"); done < <(compgen -A function)
    }

    for module_name in "$@"; do
        [[ -z "$module_name" ]] && {
            core::error "No module names given"
            return 1
        }

        match_found=false
        
        for fn in "${all_funcs[@]}"; do
            case "$fn" in
                "${module_name}."* | "${module_name}::"*)
                    __REGISTERED_COMMANDS+=("$fn")
                    match_found=true
                    "$export_mod" && export -f "${fn?}"
                    ;;
            esac
        done

        [[ ! $match_found ]] && {
            core::error "Failed to find any defined commands for module '$module_name'"
            return 1
        }

        core::verbose "[cyan]MODULE REGISTERED: ${module_name}[/]"
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
