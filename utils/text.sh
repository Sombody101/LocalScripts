#!/bin/bash

Sprint() {
    local text="$*"

    : "This will take ~$((${#text}/5)) seconds"
    for ((i = 0; i < ${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep .05
    done

    [[ "$LINE" == "TRUE" ]] && echo
}

array() {
    local -n arr="$1"
    printf '%s\n' "${arr[@]}"
}

TAB="$(printf '\t')"
NL="$(printf '\n')"

export TAB NL