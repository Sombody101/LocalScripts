#!/bin/bash

path.pathify() {
    IFS="/"
    echo "$*"
    unset IFS
}

path.prepend() {
    core::hide_trace
    [[ ! "$1" ]] && {
        core::warn "No path given to add to \$PATH"
        return 1
    }

    [[ ":$PATH:" != *":$1:"* && -d "$1" ]] && export PATH="$1:$PATH"
}

path.add() {
    core::hide_trace
    core::verbose "Adding: $1"
    [[ ! "$1" ]] && {
        core::warn "No path given to add to \$PATH"
        return 1
    }

    [[ ":$PATH:" != *":$1:"* && -d "$1" ]] && export PATH="$PATH:$1"
}

path.show() {
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
    core::hide_trace
    local path

    if [[ ! "$*" ]]; then
        path="$(wslpath -u "$(pwd)")"
    else
        path="$(wslpath -u "$*")"
    fi

    echo "$path" | tr -d "'"
}

alias wcd='path.cdtowsl'
path.cdtowsl() {
    # shellcheck disable=SC2164 # It already returns. No point adding '|| return'
    cd "$(path.towsl "$*"/ | sed 's/\\//g')"
}

path.trim_spaces() {
    export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v -E ' |/mnt/c' | paste -sd: -)"
}

array.contains() {
    local search_string
    local -n array="$1"

    shift
    search_string="$*"
    [[ " ${array[*]} " =~ [[:space:]]${search_string}[[:space:]] ]]
}

string.isnum() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

string.isstr() {
    [[ "$1" =~ ^[a-zA-z]+$ ]]
}

applyBackspaces() {
    local input="$*" char

    for ((i = 0; i < ${#input}; i++)); do
        char="${input:i:1}"
        string.isstr "$char"
    done
}

findf() {
    local file="$1" # result # dir="${2:-.}"

    if [[ -z "$file" ]]; then
        core::warn "No file name"
        return 1
    fi

    find . -type f -name "$file" 2>/dev/null
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
    local target_date current_epoch target_epoch \
        seconds months days hours minutes

    target_date="$*"
    current_epoch=$(date +%s)
    target_epoch=$(date -d "$target_date" +%s)
    seconds=$((target_epoch - current_epoch))
    months=$((seconds / 2592000))
    seconds=$((seconds % 2592000))
    days=$((seconds / 86400))
    seconds=$((seconds % 86400))
    hours=$((seconds / 3600))
    seconds=$((seconds % 3600))
    minutes=$((seconds / 60))
    seconds=$((seconds % 60))
    echo "$months months, $days days, $hours hours, $minutes minutes, $seconds seconds"
}

time.seconds_until_date() {
    local target_date current_epoch target_epoch seconds

    target_date="$*"
    current_epoch=$(date +%s)
    target_epoch=$(date -d "$target_date" +%s)
    seconds=$((target_epoch - current_epoch))

    printf "%'.f seconds\n" "$seconds"
}

flag HOME && {
    readonly D4D="/mnt/e/Downloads/hehehe/de4dot"
    alias d4d="$D4D/de4dot.exe"
}

watch() {
    [[ ! "$*" ]] && {
        core::warn "No input provided"
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
    if which "cmd.exe" >/dev/null; then
        echo "Resetting..."
        cmd.exe /C "wsl.exe" "--shutdown" # Kill
    else
        core::warn "Failed to get powershell. Is this WSL and C:\\ mounted?"
    fi
}

git.set-url() {
    ! chelp "$1" "utils.sh: git.set-url: Assign a new remote for a github repo
    git.set-url <remote name> <username> <project name>" && return

    git rev-parse 2>"/dev/null" || {
        core::warn "Not in github repo"
        return
    }

    local name="$1" token="$(token git)" username="$2" projName="$3"

    git remote set-url "$name" "https://$username:$token@github.com/$username/$projName.git" || {
        core::error "Failed tot set remote url"
        return
    }

    git remote -v
}

dir.sizes() {
    for item in ./* ./.*; do
        du -sh "$item"
    done
}

regmod path \
    array \
    string \
    time \
    git \
    dir
