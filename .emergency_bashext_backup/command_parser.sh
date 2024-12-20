#!/bin/bash

regload "$BACKS/command_parser.sh"

command_not_found_handle() {
    local cmd="$1" cmd

    if [[ "$cmd" == *"++" ]]; then
        cmd=${cmd%??}
        if [[ ${!cmd} =~ ^[0-9]+$ ]]; then
            eval "$((${!cmd} + 1))"
            return 0
        fi
    elif [[ "$cmd" == *"--" ]]; then
        cmd=${cmd%??}
        if [[ ${!cmd} =~ ^[0-9]+$ ]]; then
            eval "$((${!cmd} - 1))"
            return 0
        fi
    # Check if the command is a variable
    elif [[ "$cmd" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        local out="${!cmd}"
        [[ "$out" ]] && {
            echo "$out"
            return 0
        }

        # Check if the variable is set
        #if [ -n "$val" ]; then
        #   echo "$((val))"
        #else
        #   echo "$(blue)bash: $(yellow)$cmd: $(red)Command not found$(norm)"
        #fi
    # Check if the command is an arithmetic expression
    elif [[ "$cmd" =~ ^[0-9]+([-+*/%][0-9]+)*$ ]]; then
        echo "$(($cmd))"
        return 0
    fi

    # Otherwise, print the command not found error
    printf '%sbash: %s%s: %sCommand not found%s\n' "$BLUE" "$YELLOW" "$cmd" "$RED" "$NORM"
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
