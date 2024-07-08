#!/bin/bash

# red, orange, yellow, green, blue, indigo, and violet

happytime() {

    local DELAY=".25"

    [[ ! "$*" ]] && {
        warn "No arguments provided"
        return 1
    }

    write() {
        figlet -w 100 "$@"
    }

    while :; do
        norm
        sleep "$DELAY"
        _red
        write "$@"
        sleep "$DELAY"
        _orange
        write "$@"
        sleep "$DELAY"
        _yellow
        write "$@"
        sleep "$DELAY"
        _green
        write "$@"
        sleep "$DELAY"
        _blue
        write "$@"
        sleep "$DELAY"
        _indigo
        write "$@"
        sleep "$DELAY"
        _violet
        write "$@"
        sleep .1
    done
}
