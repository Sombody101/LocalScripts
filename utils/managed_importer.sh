#!/bin/bash

#
# This file can't use other functions or modules defined in other files because this provides the importing functionality to include them.
#

# Set search dir:
setspace() {
    local path="$*"

    if [[ ! "$path" ]] || [[ "$path" == "--" ]]; then
        # Reset path
        export __using_path="$LS"
        return 0
    fi

    export __using_path="$path"
}

alias getspace='echo "$__using_path"'
setspace "$__using_path" # Reset namespace

using() {
    [[ "$1" == "-h" ]] && {
        echo ".loader.bashrc: using"
        echo "  <file path> <option> | <-space> <path>"
        echo "  -f: Hide errors"
        echo "  -o: Verbose info"
        return
    }

    local file="$1"

    [[ "$file" == "-space" ]] && {
        shift 1
        export __using_path="$*"
        return 0
    }

    if [[ -f "$file" ]]; then
        # The file path is local
        file="$(realpath "$file")"

    # Check if arg is not an absolute path
    elif [[ ! "$file" =~ ^"/" ]]; then
        local scripts=("$__using_path/$file"*)
        local s_len="${#scripts[@]}"

        if [[ "$s_len" -gt 1 ]]; then
            # More than one script found with this name (or prefix)

            core::warn "Found multiple scripts starting with '$file':"
            for item in "${scripts[@]}"; do
                printf '\t%s\n' "$item"
            done

            add_managed_import 2 "[deeppink4_1]atmp_path:[/]" "$file"
            return 1
        fi

        file="${scripts[0]}"
    else
        [[ "$2" != '-f' ]] && {
            core::warn "Unable to find '$file'"
            add_managed_import 1 "[deeppink4_1]atmp_path:[/]" "$file"
            return 1
        }

        add_managed_import 1 "[darkviolet]soft_path:[/]" "$file"
        return 1
    fi

    add_managed_import 0 "[dodgerblue]full_path:[/]" "$(realpath "$file")"

    # shellcheck disable=SC1090
    if ! source "$file"; then
        add_managed_import 0 "[red]full_path: [[Script crashed][/]" "$(realpath "$file")"
    fi

    if [[ "$2" == '-o' ]]; then
        gecho "[blue]'$file' found [[$1]][/]"
        return 0
    fi
}

MANAGED_LOADED=()

add_managed_import() {
    [[ "$1" == "-h" ]] && {
        echo "managed_importer.sh: add_managed_import"
        echo "  <arg1> : Status code [0|1|2 found|not found|found many]"
        echo "  <arg2> : Message"
        echo "  [arg2 == \$NULL => arg2<=>arg1]"
        return
    }

    local status=1 message

    if [[ ! "$2" ]]; then
        # only one argument, assume it's good
        message="$1"
    else
        status="$1"
        message="$2"
        file="$3"
    fi

    case $status in
    0) {
        status="[steelblue1][[FOUND]"
    } ;;
    1) {
        status="[red][[VOID ]"
    } ;;
    2) {
        status="[red][[MANY ]"
    } ;;
    *) {
        status="$1[[$2]"
        shift 2
        message="$*"
    } ;;
    esac

    MANAGED_LOADED+=("$(gecho "$status $message [darkorange]$file"'[/]')")
}

add_random_import() {
    MANAGED_LOADED+=("$*")
}

# Same as 'loaded', but less involvment
alias mimports='array MANAGED_LOADED'

LOADED=()

regload() {
    __add_reg "[[[magenta]+[/]]:" "$*"
}

regnload() {
    __add_reg "[[[red]-[/]]:" "$*"
}

__add_reg() {
    LOADED+=("$(gecho "$1 [darkorange]$2[/]")")
}

alias loaded='array LOADED'

track() {
    local cmd="$1"
    shift

    : "${CYAN}ENTER: $YELLOW$cmd$CYAN :ENTER$NORM"
    $cmd "$@"
    local ret="$?"
    : "${CYAN}EXIT: $YELLOW$cmd$CYAN :EXIT$NORM"

    # return commands code
    return "$ret"
}
