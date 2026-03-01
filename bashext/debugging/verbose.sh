#!/bin/bash

[[ ! "$VERBOSE" ]] && export VERBOSE=FALSE

vset() {
    if [[ "$1" == "true" ]]; then
        export VERBOSE=TRUE
        return 0
    elif [[ "$1" == "false" ]]; then
        export VERBOSE=FALSE
        return 0
    fi

    warn "Unknown setting '$1'"
}

verbose() {
    : "Verbose check: $VERBOSE"

    [[ "$VERBOSE" == "FALSE" ]] && {
        return 1
    }

    local stack
    stack="$(core::trace)"
    stack="${stack:-ROOT}"
    echo "[$stack]: $*"
}
