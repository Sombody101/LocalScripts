#!/bin/bash

path.pathify() {
    : "bashext: path.pathify"
    IFS="/"
    echo "$*"
    unset IFS
}

path.top() {
    : "bashext: path.top"
    [[ ! "$1" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! "$PATH" =~ $1 ]] && export PATH="$1:$PATH"
}

path.add() {
    : "bashext: path.add"
    [[ ! "$1" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! "$PATH" =~ $1 ]] && export PATH="$PATH:$1"
}

path.show() {
    : "bashext: path.show"
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

path.cdtowsl() {
    : "path.cdtowsl: Calls 'path.towsl' and automatically CDs into the returned directory"
    cd "$(path.towsl "$*"/)"
}

alias wcd='path.cdtowsl'

file.exists() {
    [[ -f "$1" ]]
}

array.contains() {
    : "array.contains: Check if an array contains a substring | <arr_name> <substring ...>"

    local search_string
    local -n array="$1"

    shift
    search_string="$*"
    [[ " ${array[*]} " =~ [[:space:]]${search_string}[[:space:]] ]]
}

string.isnum() {
    [[ $1 =~ ^[0-9]+$ ]]
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
    local file="$1" result # dir="${2:-.}"

    if [[ -z "$file" ]]; then
        warn "No file name"
        return 1
    fi

    find . -type f -name "$file" 2>/dev/null
}

# Get a command stack trace (debugging)
trace() {
    local stack skip="${1:-2}" prefix="$2" suffix="${3:-:}"

    for f in "${FUNCNAME[@]:$skip}"; do
        if [[ "$stack" ]]; then
            stack="$CYAN$f$YELLOW>$CYAN$stack"
        else
            stack="$prefix$CYAN$f"
        fi
    done

    stack="$stack$suffix"

    [[ "$stack" == "${prefix}${suffix}" ]] && {
        # No stack was found, so just return nothing
        return
    }

    echo "$stack$NORM"
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
    D4D="/mnt/e/Downloads/hehehe/de4dot"
    d4d() {
        "$D4D/de4dot.exe" "$@"
    }
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
    if which "cmd.exe" >/dev/null; then
        echo "Resetting..."
        cmd.exe /C "wsl.exe" "--shutdown" # Kill
    else
        core::warn "Failed to get powershell. Is this WSL and C:\\ mounted?"
    fi
}

git.set-url() {
    ! chelp $1 "utils.sh: git.set-url: Assign a new remote for a github repo
    git.set-url <remote name> <username> <project name>" && return

    git rev-parse 2>"/dev/null" || {
        core::warn "Not in github repo"
        return 1
    }

    local name="$1" token="$(token git)" username="$2" projName="$3"

    git remote set-url "$name" "https://$username:$token@github.com/$username/$projName.git" || {
        core::error "Failed tot set remote url"
        return 1
    }

    git remote -v
}

dir.sizes() {
    for item in $(ls -a); do
        du -sh "$item"
    done
}

cpair() {
    local filename="$1"

    [[ ! "$filename" ]] && {
        core::warn "No file name given"
        return 1
    }

    local file_h="$filename.h" \
        file_cpp="$filename.cpp" \
        exit=

    [[ -f "$file_h" ]] && {
        core::warn "The file $file_h already exists"
        exit="true"
    }

    [[ -f "$file_cpp" ]] && {
        core::warn "The file $file_cpp already exists"
        exit="true"
    }

    [[ "$exit" ]] && return 1

    touch "$file_h"

    {
        echo "#ifndef ${filename}_h"
        echo "#define ${filename}_h"
        echo
        echo "#endif"
    } >>"$file_h"

    touch "$file_cpp"
    echo "#include \"$file_h\"" >>"$file_cpp"
}

register_module path \
    file \
    array \
    string \
    time \
    git \
    dir
