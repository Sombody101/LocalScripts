#!/bin/bash

MANAGED_LOADED=()

add_managed_import() {
    : "managed_importer.sh: add_managed_import"
    MANAGED_LOADED+=("$*")
}

# Same as 'loaded', but less involvment
alias mimports='array MANAGED_LOADED'

track() {
    local cmd="$1"
    shift

    : "$(cyan)ENTER: $cmd :ENTER$(norm)"
    $cmd "$@"
    : "$(cyan)ENTER: $cmd :EXIT$(norm)"
}