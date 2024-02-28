#!/bin/bash

regload "showcase.sh (For Linux+)"

alias NOPS='while :; do sleep 10; done'

fillcolor() {
    local w=$(tput cols)
    ((w--))
    local h=$(tput lines)

    tput cup 0 0
    for ((i = 0; i < h; i++)); do
        for ((x = 0; x < w; x++)); do
            local color=$((RANDOM % 8 + 40))
            printf "\e[%sm " "$color"
        done

        [[ ! "$i" -eq "$h" ]] && echo
    done
}

fillcolorline() {
    local w=$(tput cols)
    ((w--))
    local h=$(tput lines)

    tput cup 0 0
    for ((i = 0; i < h; i++)); do
        local color=$((RANDOM % 8 + 40))

        for ((x = 0; x < w; x++)); do
            printf "\e[%sm " "$color"
        done

        [[ ! "$((i + 1))" -eq "$h" ]] && echo
    done
}

fillcolorcol() {
    local w=$(tput cols)
    ((w--))
    local h=$(tput lines)
    local cols=()

    for ((c = 0; c < w; c++)); do
        cols[c]=$((RANDOM % 8 + 40))
    done

    tput cup 0 0
    local b=
    white
    for ((i = 0; i < h; i++)); do
        for ((x = 0; x < w; x++)); do
            printf "\e[%sm " "${cols[x]}"
        done

        [[ ! "$((i + 1))" -eq "$h" ]] && echo
    done
}

fillcolorcoltext() {
    local w=$(tput cols)
    ((w--))
    local h=$(tput lines)
    local cols=()

    for ((c = 0; c < w; c++)); do
        cols[c]=$((RANDOM % 8 + 40))
    done

    tput cup 0 0
    local b=
    white
    for ((i = 0; i < h; i++)); do
        for ((x = 0; x < w; x++)); do
            b=$(openssl rand -base64 1)
            printf "\e[%sm%s" "${cols[x]}" "${b:0:1}"
        done

        [[ ! "$((i + 1))" -eq "$h" ]] && echo
    done
}

fillcolortext() {
    local w=$(tput cols)
    ((w--))
    local h=$(tput lines)

    tput cup 0 0
    local b=
    for ((i = 0; i < h; i++)); do
        for ((x = 0; x < w; x++)); do
            local color=$((RANDOM % 8 + 40))
            b=$(openssl rand -base64 1)
            printf "\e[%sm%s" "$color" "${b:0:1}"
        done

        [[ ! "$((i + 1))" -eq "$h" ]] && echo
    done
}
