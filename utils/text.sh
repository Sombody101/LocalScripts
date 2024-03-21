#!/bin/bash
Sprint() {
    lcoal text="$*"
    for ((i = 0; i < ${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep .05
    done

    [[ $LINE == "TRUE" ]] && echo
}

array() {
    local -n arr="$1"
    for i in "${arr[@]}"; do
        echo "$i"
    done
}

TAB="$(printf '\t')"
NL="$(printf '\n')"
