#!/bin/bash

debug() {
    export DEBUG=1
    set -x
}

debug-stop() {
    unset DEBUG
    set +x
}