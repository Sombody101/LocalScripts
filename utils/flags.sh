#!/bin/bash

declare -g -A FLAG_MAP=(
    ["HOME"]="hdev"
    ["MOBILE"]="sdev"
    ["WSL"]="WSL"
    ["SERVER"]="server"
    ["UNKNOWN"]="unknown"
    ["DEBUG"]="DEBUG"
    ["VERBOSE"]="VERBOSE"
)

core::flag() {
    core::hide_trace

    local exit_code=0 arg var_name

    [[ "$1" =~ any|or ]] && core::warn "Use of '$1' when it's no longer implemented."

    for arg in "$@"; do
        var_name=${FLAG_MAP[$arg]}

        if [[ -n "$var_name" ]]; then
            [[ -z "${!var_name}" ]] && {
                exit_code=1
            }
        else
            core::warn "Unknown flag: $arg"
            [[ $exit_code -eq 0 || $exit_code -eq 1 ]] && exit_code=2
        fi
    done

    return $exit_code
}

alias flag='core::flag'
