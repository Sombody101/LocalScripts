#!/bin/bash

# Import-Packages
impacks() {
    local updstr

    updstr="$(red)<=== Content Refreshed ===>$(norm)"
    regload "$updstr"

    using "$BACKS/bashext.sh"
}

padr() {
    : "utils: padr"
    printf "%${!1}s" "${@:2}"
}

padl() {
    :
}

binToDec() {
    : "utils: binToDec"
    for arg in "$@"; do
        isnum "$arg" || {
            warn "$arg contains non-binary character"
            return 1
        }
    done

    for arg in "$@"; do
        echo "$((2#$arg))"
    done
}

binToHex() {
    : "utils: binToHex"
    for arg in "$@"; do
        isnum "$arg" || {
            warn "$arg contains non-binary character"
            return 1
        }
    done

    for arg in "$@"; do
        printf '%x\n' "$((2#$arg))"
    done
}

decToBin() {
    : "utils: decToBin"
    for arg in "$@"; do
        isnum "$arg" || {
            warn "$arg contains non-binary character"
            return 1
        }
    done

    LC_ALL=C awk '{for (i = 1; i <= NF; i++) printf "%c", $i}'
    perl -ape '$_=pack("C*",@F)'
}

hexToBin() {
    : "utils: hexToBin"
    xxd -r -p
    perl -pe 'chomp;$_=pack("H*",$_)'
}
