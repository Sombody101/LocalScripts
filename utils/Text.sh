#!/bin/bash
Sprint() {
    Text="$*"
    #OP1="-t
    #if [[ "$STR" == *"$SUB"* ]]; then
    for ((i = 0; i < ${#Text}; i++)); do
        echo -ne "${Text:$i:1}"
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
