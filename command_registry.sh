#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

#alias register_module='core::obsolete register_module regmod; regmod'
obsolete register_module regmod

regmod() {
    core::hide_trace
    local export_mod=false module_name fn_list

    [[ "$1" == "export" ]] && {
        export_mod=true
        shift
    }

    local -A fn_index=()
    local name ns

    while read -r name; do
        ns=""
        case "$name" in
            *.*)  ns="${name%%.*}" ;;
            *::*) ns="${name%%::*}" ;;
        esac

        [[ -n "$ns" ]] && fn_index["$ns"]+="$name "
    done < <(compgen -A function)

    for module_name in "$@"; do
        [[ -z "$module_name" ]] && {
            core::error "No module names given"
            return
        }

        fn_list="${fn_index[$module_name]}"

        [[ -z "$fn_list" ]] && {
            core::error "Failed to find any defined commands for module '$module_name'"
            return
        }

        local matched_cmds=($fn_list)

        __REGISTERED_COMMANDS+=("${matched_cmds[@]}")
        $export_mod && export -f "${matched_cmds[@]}"

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
