#!/bin/bash

function winalias() {
    command -v "$1" > /dev/null || {
        alias "$1"="core::error 'Failed to bind \`$1\`, unable to locate Windows binary or command'"
        return 1
    }

    alias "$1"="$2"
}

winalias clip clip.exe
winalias pshell powershell.exe
winalias nothing nothing.exe

unset -f winalias
