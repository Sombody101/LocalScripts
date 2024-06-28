#!/bin/bash

occ() {
    : "bashext: occ"
    while :; do
        form -a "$@"
    done
}

path.pathify() {
    : "bashext: pathify"
    IFS="/"
    echo "$*"
    unset IFS
}

warn() {
    : "bashext: warn"
    echo -e "$(trace): $RED$*$NORM"
}

path.toppath() {
    : "bashext: addpath"
    [[ ! "$1" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! "$PATH" =~ $1 ]] && export PATH="$1:$PATH"
}

path.botpath() {
    : "bashext: addpath"
    [[ ! "$1" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! "$PATH" =~ $1 ]] && export PATH="$PATH:$1"
}

path.showpath() {
    : "bashext: showPath"
    tr ':' '\n' <<<"$PATH"
}

path.towin() {
    if [[ ! "$*" ]]; then
        wslpath -w "$(pwd)"
    else
        wslpath -w "$*"
    fi
}

path.towsl() {
    : "path.towsl: Transform a Windows path to a WSL compatible path"

    local path

    if [[ ! "$*" ]]; then
        path="$(wslpath -u "$(pwd)")"
    else
        path="$(wslpath -u "$*")"
    fi

    printf "%q\n" "$path" | tr -d "'"
}

file.exists() {
    [[ -f "$1" ]]
    return "$?" 
}

array.contains() {
    : "array.contains: Check if an array contains a substring | <arr_name> <substring ...>"

    local -n array="$1"
    shift
    search_string="$*"
    if [[ " ${array[*]} " =~ [[:space:]]${search_string}[[:space:]] ]]; then
        return 0
    fi
    return 1
}

string.isnum() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    fi
    return 1
}

string.isstr() {
    if [[ $1 =~ ^[a-zA-z]+$ ]]; then
        return 0
    fi
    return 1
}

applyBackspaces() {
    local input="$*"

    for ((i = 0; i < ${#input}; i++)); do
        char="${input:i:1}"
        isstr "$char" && continue
    done
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
        [[ "$stack" ]] && stack="$(cyan)$f" || stack="$(cyan)$f$(yellow)>$(cyan)$stack"
    done

    echo "$stack$(norm)"
}

# Print variables and their values (debugging)
lvar() {
    local count=0

    for var in "$@"; do
        echo "$count: $var: \`${!var}\`"
        ((count++))
    done
}

time_until_date() {
    local target_date="$*"
    local current_epoch=$(date +%s)
    local target_epoch=$(date -d "$target_date" +%s)
    local seconds=$((target_epoch - current_epoch))
    local months=$((seconds / 2592000))
    seconds=$((seconds % 2592000))
    local days=$((seconds / 86400))
    seconds=$((seconds % 86400))
    local hours=$((seconds / 3600))
    seconds=$((seconds % 3600))
    local minutes=$((seconds / 60))
    seconds=$((seconds % 60))
    echo "$months months, $days days, $hours hours, $minutes minutes, $seconds seconds"
}

# Shits-n-giggles
bday() {
    time_until_date "2024-07-07 12:00:00"
}

lday() {
    time_until_date "2024-05-28 12:00:00"
}

watch() {
    local type="$1"

    shift
    local inputs=("$@")

    [[ "${#inputs[@]}" -eq 0 ]] && {
        warn "No inputs provided"
    }

    local op=
    case $type in
    "-v") op='echo "${!item}"' ;;
    "-c") op='echo "$(item)"' ;;
    esac

    local item="${inputs[1]}"
    while :; do
        eval "$op"
        sleep .1
    done
}
