#!/bin/bash

vset() {
    local v=${1:-true}
    if [[ "$v" == "true" ]]; then
        export VERBOSE=TRUE
        return 0
    elif [[ "$v" == "false" ]]; then
        unset VERBOSE
        return 0
    fi

    warn "Unknown setting '$1'"
}

verbose() {
    core::warn "Call to legacy 'verbose'. Change it to 'core::verbose'"
    core::verbose "$@"
    return

    core::hide_trace
    [[ ! "$VERBOSE" ]] && {
        return 1
    }

    local stack
    stack="$(core::trace)"
    stack="${stack:-ROOT}"
    core::show_trace
    gecho "$stack $*"
}
