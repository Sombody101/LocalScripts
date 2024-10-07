#!/bin/bash

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
    : ".loader.bashrc: using"
    : "<file path> <option>"
    : "-f: Hide errors"
    : "-o: Verbose info"

    local file="$1"

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

            add_managed_import 2 "$(_indigo)atmp_path:$NORM $file"
            return 1
        fi

        file="${scripts[0]}"
    else
        [[ "$2" != '-f' ]] && {
            core::warn "Unable to find '$file'"
            add_managed_import 1 "$(_indigo)atmp_path:$NORM $file"
            return 1
        }

        add_managed_import 1 "${MAGENTA}soft_path:$NORM $file"
        return 1
    fi

    add_managed_import 0 "${CYAN}full_path:$NORM $(realpath "$file")"

    if ! source "$file" 2>/dev/null; then
        add_managed_import "$RED" "ERROR" "${RED}full_path:$NORM $(realpath "$file")"
    fi

    if [[ "$2" == '-o' ]]; then
        echo "$BLUE'$file' found [$1]$NORM"
        return 0
    fi
}

MANAGED_LOADED=()

add_managed_import() {
    : "managed_importer.sh: add_managed_import"
    : "<arg1> : Status code"
    : "<arg2> : Message"
    : "[arg2 == \$NULL => arg2<=>arg1]"

    local status=1 message

    if [[ ! "$2" ]]; then
        # only one argument, assume it's good
        message="$1"
    else
        status="$1"
        message="$2"
    fi

    case $status in
    0) {
        status="${BLUE}[FOUND]"
    } ;;
    1) {
        status="${RED}[NOT F]"
    } ;;
    2) {
        status="${RED}[NOT*F]"
    } ;;
    *) {
        status="$1[$2]"
        shift 2
        message="$*"
    } ;;
    esac

    MANAGED_LOADED+=("$status $message")
}

add_random_import() {
    MANAGED_LOADED+=("$*")
}

# Same as 'loaded', but less involvment
alias mimports='array MANAGED_LOADED'

LOADED=()

regload() {
    LOADED+=("[$MAGENTA+$NORM]:  $*")
}

regnload() {
    LOADED+=("[$RED-$NORM]:  $*")
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
