#!/bin/bash

A_Has() {
    search_string=$1
    shift
    if grep -q "$search_string" "$@"; then
        return 0
    fi
    return 1
}

isnum() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    fi
    return 1
}

isstr() {
    if [[ $1 =~ ^[a-zA-z]+$ ]]; then
        return 0
    fi
    return 1
}

shrinkArr() {
    echo "$*"
}

applyBackspaces() {
    local input=$*

    for ((i = 0; i < ${#input}; i++)); do
        char="${input:i:1}"
        isstr $char && continue
    done
}

toWin() {
    if [[ $* == "" ]]; then
        wslpath -w "$(pwd)"
    else
        wslpath -w "$1"
    fi
}

toWsl() {
    local path
    if [[ $* == "" ]]; then
        path="$(wslpath -u "$(pwd)")"
    else
        path="$(wslpath -u "$1")"
    fi
    printf "%q" "$path" | tr -d "'"
    echo
}

findf() {
    local file="$1"
    local dir="${2:-.}"

    if [[ -z "$file" ]]; then
        warn "No file name"
        return 1
    fi

    local result=$(find . -type f -name "$file" 2>/dev/null)

    if [[ -n "$result" ]]; then
        echo "$result"
    fi
}

trace() {
    local stack

    for f in "${FUNCNAME[@]:2}"; do
        [[ $stack == "" ]] && stack="$(cyan)$f" || stack="$(cyan)$f$(yellow)>$(cyan)$stack"
    done

    printf '%s' "$stack$(norm)"
}

bday() {
    target_date="2024-07-07 12:00:00"
    current_epoch=$(date +%s)
    target_epoch=$(date -d "$target_date" +%s)
    seconds_remaining=$((target_epoch - current_epoch))
    months=$((seconds_remaining / 2592000))
    seconds_remaining=$((seconds_remaining % 2592000))
    days=$((seconds_remaining / 86400))
    seconds_remaining=$((seconds_remaining % 86400))
    hours=$((seconds_remaining / 3600))
    seconds_remaining=$((seconds_remaining % 3600))
    minutes=$((seconds_remaining / 60))
    seconds=$((seconds_remaining % 60))
    echo "$months months, $days days, $hours hours, $minutes minutes, $seconds seconds"
}
