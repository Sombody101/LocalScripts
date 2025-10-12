#!/bin/bash

# Get a command stack trace (debugging)
core::trace_legacy() {
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

core::trace() {
    : "core.sh: core::trace"

    [[ "$4" == '-s' ]] && return

    local stack skip="${1:-2}" prefix="$2" suffix="${3:-:}"

    # BASH_SOURCE: File
    # BASH_LINENO: Line
    # FUNCNAME: Command
    local file line command len="${#FUNCNAME[@]}"

    [[ "${BASH_SOURCE[len - 1]}" == *"/.profile" ]] && ((len -= 2))
    [[ "${BASH_SOURCE[len - 1]}" == *"/.bashrc" ]] && ((len--))

    for ((i = skip; i < len; ++i)); do
        file="$(basename "${BASH_SOURCE[i]}")"
        line="${BASH_LINENO[i]}"
        command="${FUNCNAME[i]}"

        stack="${CYAN}${file}@${command}():${line}${YELLOW}>${CYAN}${stack}"
    done

    echo "${stack}${NORM}"
}

obsolete() {
    core::error "Not implemented yet"
}

__print_log() {
    # "<color> [-s] <message>"

    local color="$1" trace
    shift

    if [[ "$1" == '-s' ]]; then
        shift
    else
        trace="$(core::trace '3' '' ': ' "$1") "
    fi

    printf '%s%s%s%s\n' "$trace" "$color" "$*" "$NORM" >&2
}

core::error() {
    : "core.sh: core::error"
    __print_log "$RED" "$@"
    #printf '%s %s%s%s\n' "$(core::trace '2' '' ': ' "$1")" "$RED" "$*" "$NORM" >&2
    return 4
}

core::warn() {
    : "core.sh: core::warn"
    __print_log "$YELLOW" "$@"
    #printf '%s %s%s%s\n' "$(core::trace '2' '' ': ' "$1")" "$YELLOW" "$*" "$NORM" >&2
    return 3
}

warn() {
    core::warn "[CORE] Update from obsolete warn to core::warn"
    core::warn "$@"
}

error() {
    core::warn "[CORE] Update from obsolete error to core::error"
    core::error "$@"
}
