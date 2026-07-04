#!/bin/bash

debug() {
    export DEBUG=1
    set -x

    [[ "$1" ]] && debug-stop
}

debug-stop() {
    unset DEBUG
    set +x
}