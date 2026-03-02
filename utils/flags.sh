#!/bin/bash

core::flag() {
    : "Options: HOME_DEV, MOBILE_DEV, WSL, SERVER, UNKNOWN"
    : "Returns: 0 if all flags are set, 1 otherwise (including unknown flags)"
    local exit_code=0

    for arg in "${@:1}"; do
        case "$arg" in
        "HOME")
            : "Checking hdev"
            [[ ! "$hdev" ]] && exit_code=1
            ;;
        "MOBILE")
            : "Checking sdev"
            [[ ! "$sdev" ]] && exit_code=1
            ;;
        "WSL")
            : "Checking WSL"
            [[ ! "$WSL" ]] && exit_code=1
            ;;
        "SERVER")
            : "Checking server"
            [[ ! "$server" ]] && exit_code=1
            ;;
        "UNKNOWN")
            : "Checking unknown"
            [[ ! "$unknown" ]] && exit_code=1
            ;;
        *)
            core::warn "Unknown flag: $arg"
            exit_code=2
            ;;
        esac
    done

    return $exit_code
}

alias flag='core::flag'