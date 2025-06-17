#!/bin/bash

regload "$BACKS/command_parser.sh"

command_not_found_handle() {
    local cmd="$1"

    # Check if the command is a variable
    if [[ "$cmd" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        local out="${!cmd}"
        [[ "$out" ]] && {
            echo "$out"
            return
        }
    fi

    # Otherwise, print the command not found error
    printf '%sbash: %s%s: %sCommand not found%s\n' "$BLUE" "$YELLOW" "$cmd" "$RED" "$NORM"
    # __report_command "$cmd"
    return 127
}

__report_command() {
    if [ -x /usr/lib/command-not-found ]; then
        /usr/lib/command-not-found -- "$1"
        return $?
    else
        if [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf '%sbash: %s%s: %sCommand not found%s\n' "$BLUE" "$YELLOW" "$cmd" "$RED" "$NORM"
            return 127
        fi
    fi
}

alias search='__report_command'
