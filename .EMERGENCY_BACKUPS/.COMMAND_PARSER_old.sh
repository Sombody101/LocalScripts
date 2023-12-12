#!/bin/bash

#command_not_found_handle() {
#    local args=($*)
#    local cmd=${args[0]}
#
#    if [[ $cmd == *"++" ]]; then
#        local TMP=${cmd//++/}
#        local num=$(( TMP + 1 ))
#        declare "$TMP=$num"
#        export $TMP
#        return
#    fi
#    echo $(blue)bash: $(yellow)$cmd: $(red)Command not found
#}

command_not_found_handle() {
    local cmd="$1"

    # Check if the command is a variable
    if [[ "$cmd" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        local out="${!cmd}"
        [[ "$out" != "" ]] && {
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
    echo "$(blue)bash: $(yellow)$cmd: $(red)Command not found$(norm)"
    return 1
}
