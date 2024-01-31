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

    printf "%q\n" "$path" | tr -d "'"
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

# Get a command stack trace (debugging)
trace() {
    local stack

    for f in "${FUNCNAME[@]:2}"; do
        [[ "$stack" == "" ]] && stack="$(cyan)$f" || stack="$(cyan)$f$(yellow)>$(cyan)$stack"
    done

    printf '%s' "$stack$(norm)"
}

# Print variables and their values (debugging)
lvar() 
{
    local count=0
    
    for var in "$@"; do
        echo "$count: $var: \`${!var}\`"
        ((count++))
    done
}

# Shits-n-giggles
bday() {
    local target_date="2024-07-07 12:00:00"
    local current_epoch=$(date +%s)
    local target_epoch=$(date -d "$target_date" +%s)
    local seconds_remaining=$((target_epoch - current_epoch))
    local months=$((seconds_remaining / 2592000))
    local seconds_remaining=$((seconds_remaining % 2592000))
    local days=$((seconds_remaining / 86400))
    local seconds_remaining=$((seconds_remaining % 86400))
    local hours=$((seconds_remaining / 3600))
    local seconds_remaining=$((seconds_remaining % 3600))
    local minutes=$((seconds_remaining / 60))
    local seconds=$((seconds_remaining % 60))
    echo "$months months, $days days, $hours hours, $minutes minutes, $seconds seconds"
}

lday() {
    local target_date="2024-05-28 12:00:00"
    local current_epoch=$(date +%s)
    local target_epoch=$(date -d "$target_date" +%s)
    local seconds_remaining=$((target_epoch - current_epoch))
    local months=$((seconds_remaining / 2592000))
    local seconds_remaining=$((seconds_remaining % 2592000))
    local days=$((seconds_remaining / 86400))
    local seconds_remaining=$((seconds_remaining % 86400))
    local hours=$((seconds_remaining / 3600))
    local seconds_remaining=$((seconds_remaining % 3600))
    local minutes=$((seconds_remaining / 60))
    local seconds=$((seconds_remaining % 60))
    echo "$months months, $days days, $hours hours, $minutes minutes, $seconds seconds"
}
