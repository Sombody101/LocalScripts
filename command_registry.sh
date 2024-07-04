#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

register_command() {
    warn "Don't use this"
    return

    local command_name description formatted_string

    command_name="$1"
    shift
    description="$*"

    formatted_string=$(printf '%*s : %s' "$command_name" "$_PAD_SIZE" "$description")
    __REGISTERED_COMMANDS+=("$formatted_string")
}

register_module() {
    local module_name cmds

    while [[ "$*" ]]; do
        module_name="$1"

        [[ ! "$module_name" ]] && {
            warn "No module names given"
            return 1
        }

        cmds=()

        while IFS= read -r cmd; do
            [[ $cmd =~ ^$module_name ]] && cmds+=("$cmd")
        done < <(declare -F | cut -d ' ' -f 3 | grep ^"$module_name.")

        [[ "${#cmds[@]}" -eq 0 ]] && {
            warn "Failed to find any defined commands for module '$module_name'"
            return 1
        }

        __REGISTERED_COMMANDS+=("${cmds[@]}")

        : "${CYAN}MODULE REGISTERED: $module_name$NORM"

        shift
    done
}

#alias cmds='array __REGISTERED_COMMANDS'

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
