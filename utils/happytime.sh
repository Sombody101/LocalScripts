#!/bin/bash

# red, orange, yellow, green, blue, indigo, and violet

happytime() {
    [[ ! "$*" ]] && {
        warn "No arguments provided"
        return 1
    }

    write() {
        figlet -w 100 "$@"
    }

    while :; do
        norm
        sleep .1
        _red
        write "$@"
        sleep .1
        _orange
        write "$@"
        sleep .1
        _yellow
        write "$@"
        sleep .1
        _green
        write "$@"
        sleep .1
        _blue
        write "$@"
        sleep .1
        _indigo
        write "$@"
        sleep .1
        _violet
        write "$@"
        sleep .1
    done
}
