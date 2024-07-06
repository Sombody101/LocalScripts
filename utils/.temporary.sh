#!/bin/bash

#
# Temporary functions that will be overridden later. These are here in case of a critical error or BashExt fails to load.
#

showPath() {
    : ".loader: listPath [TEMPORARY]"
    local tmp=$PATH
    IFS=':'

    read -ra arr <<<"$tmp"
    for item in "${arr[@]}"; do
        echo "$item"
    done
}

warn() {
    : ".loader: warn [TEMPORARY]"
    echo "$RED$*$NORM"
}
