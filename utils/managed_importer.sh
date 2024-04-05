#!/bin/bash

MANAGED_LOADED=()

add_managed_import() {
    : "managed_importer.sh: add_managed_import"
    MANAGED_LOADED+=("$*")
}

# Same as 'loaded', but less involvment
alias mimports='array MANAGED_LOADED'

LOADED=()

regload() {
    LOADED+=("[$MAGENTA+$NORM]:  $*")
}

regnload() {
    LOADED+=("[$RED-$NORM]:  $*")
}

alias loaded='array LOADED'

track() {
    local cmd="$1"
    shift

    : "$CYAN\ENTER: $cmd :ENTER$NORM"
    $cmd "$@"
    local ret="$?"
    : "$CYAN\ENTER: $cmd :EXIT$NORM"

    # return commands code
    return "$ret"
}