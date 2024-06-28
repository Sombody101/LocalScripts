#!/bin/bash

__REGISTERED_COMMANDS=()
_PAD_SIZE=20

register_command() {
    local command_name="$1"
    shift
    local description="$*"

    local formatted_string=$(printf '%*s : %s' "$command_name" "$_PAD_SIZE" "$description")
    __REGISTERED_COMMANDS+=("$formatted_string")
}

alias cmds='array __REGISTERED_COMMANDS'