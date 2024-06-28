#!/bin/bash

export VERBOSE=FALSE

vset() {
    if [[ "$1" == "true" ]]; then
        VERBOSE=TRUE
        return 0
    elif [[ "$1" == "false" ]]; then
        VERBOSE=FALSE
        return 0
    fi

    warn "Unknown setting '$1'"
}

verbose() {
    : "Verbose check: $VERBOSE"
    [[ "$VERBOSE" == "FALSE" ]] && {
        return 1
    }

    local stack="$(trace)"
    stack="${stack:-ROOT}"
    echo "[$stack]: $*"
}
