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
    printf '%s: %s%s%s\n' "$(trace)" "$RED" "$*" "$NORM" >&2
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

time.until_date() {
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

time.seconds_until_date() {
    local target_date="$*"
    local current_epoch=$(date +%s)
    local target_epoch=$(date -d "$target_date" +%s)
    local seconds=$((target_epoch - current_epoch))

    printf "%'.f seconds\n" "$seconds"
}

flag HOME && {
    D4D="/mnt/e/Downloads/hehehe/de4dot"
    d4d() {
        "$D4D/de4dot.exe" "$@"
    }
}

# Shits-n-giggles
bday() {
    time.until_date "2024-07-07 12:00:00"
}

lday() {
    time.until_date "2024-05-23 12:00:00"
}

watch() {
    [[ ! "$*" ]] && {
        warn "No input provided"
    }

    local type="$1"
    local input="$2"

    clear

    case $type in
    "-v") {
        while :; do
            tput cup 0 0
            echo -e "${!input}\r"
            sleep .5
        done
    } ;;
    "-c") {
        while :; do
            tput cup 0 0
            eval "$input"
            echo -e "\r"
            sleep .5
        done
    } ;;
    esac
}

resetwsl() {
    if which "cmd.exe" >$NULL; then
        echo "Resetting..."
        cmd.exe /C "wsl.exe" "--shutdown" # Kill
    else
        warn "Failed to get powershell. Is this WSL and C:\\ mounted?"
    fi
}

git.set-url() {
    : "Assign a new remote for a github repo"
    : "<remote name> <github token> <username> <project name>"
    : "origin some_token username project_name"

    git rev-parse 2>"$NULL" || {
        warn "Not in github repo"
        return 1
    }

    local name="$1"
    local token="$2"
    local username="$3"
    local projName="$4"

    git remote set-url "$name" "https://$username:$token@github.com/$username/$projName.git" || {
        warn "Failed to set remote url"
        return 1
    }

    git remote -v
}

register_module path file array string time git
