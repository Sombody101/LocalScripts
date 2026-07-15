#!/bin/bash

# DEFINE: FORCE_DEBUG # Forces xtrace logs, even if `core::hide_trace` is used on a function. Doesn't apply to `core::ignore_trace`

[[ ! "$PATH" == *"$HOME/.local/bin"* ]] && export PATH="$PATH:$HOME/.local/bin"

# Check if a command exists
cmdchk() {
    command -v "$1" &>/dev/null
}

# shellcheck disable=SC2142
alias 'core::skip'='{ if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then exit 101; else return 101; fi; }'
alias 'core::hide_trace'='{ [[ ! -v BASH_XTRACEFD && ! "$FORCE_DEBUG" ]] && { local BASH_XTRACEFD; exec {BASH_XTRACEFD}>/dev/null; } } 2>/dev/null'
alias 'core::ignore_trace'='{ local BASH_XTRACEFD; exec {BASH_XTRACEFD}>/dev/null; } 2>/dev/null'
alias 'core::show_trace'='{ unset BASH_XTRACEFD; } 2>/dev/null'

if ! cmdchk 'core::hide_trace'; then
    # Prevents errors in non-interactive instances
    function core::skip() { :; }
    function core::hide_trace() { :; }
    function core::ignore_trace() { :; }
    function core::show_trace() { :; }
fi

# Get a command stack trace (debugging)
core::trace_legacy() {
    local stack skip="${1:-2}" prefix="$2" suffix="${3:-:}"

    for f in "${FUNCNAME[@]:$skip}"; do
        if [[ "$stack" ]]; then
            stack="${CYAN}${f}${YELLOW}>${CYAN}${stack}"
        else
            stack="$prefix$CYAN$f"
        fi
    done

    stack="$stack$suffix"

    [[ "$stack" == "${prefix}${suffix}" ]] && {
        # No stack was found, so just return nothing
        return
    }

    echo "${stack}${NORM}"
}

core::trace() {
    core::ignore_trace
    [[ "$4" == '-s' ]] && return

    local stack skip="${1:-2}" prefix="$2" suffix="${3:-:}"

    # BASH_SOURCE: File
    # BASH_LINENO: Line
    # FUNCNAME: Command
    local file line command len="${#FUNCNAME[@]}" 
    local bsrc="${BASH_SOURCE[len - 1]}" 

    [[ "$bsrc" == *"/.profile" ]] && ((len -= 2))
    [[ "$bsrc" == *"/.bashrc" ]] && ((len--))

    for ((i = skip; i < len; ++i)); do
        file="$(basename "${BASH_SOURCE[i]}")"
        line="${BASH_LINENO[i]}"
        command="${FUNCNAME[i]}"

        stack="[cyan]${file}@${command}():${line}[yellow]>${stack}"
    done

    echo "$stack"
}

core::create_config() {
    [[ -f "$HOME/.lsconfig.sh" && ! "$1" == "-f" ]] && {
        core::warn "Config file already exists at $HOME/.lsconfig.sh"
        return 1
    }

    cp "$LS/config/config.sh" "$HOME/.lsconfig.sh"
    echo "Config created at $HOME/.lsconfig.sh"
}

#
# Logging
#

__print_log() {
    # "<color> [-s] <message>"
    core::hide_trace

    local color="$1" trace
    shift

    if [[ "$2" == '-s' ]]; then
        shift 2
    else
        trace="$(core::trace '3' '' ': ' "$1" :) "
    fi

    gecho "${trace# }[${color}]${*}[/]" >&2
}

core::error() {
    __print_log red "$@"
    return 4
}

core::warn() {
    __print_log yellow "$@"
    return 3
}

core::info() {
    __print_log deepskyblue "$@"
    return 0
}

core::success() {
    __print_log green "$@"
    return 0
}

core::verbose() {
    core::hide_trace
    [[ ! "$VERBOSE" ]] && return 0
    core::show_trace

    __print_log magenta "verbose:" "$@"
    return 0
}

core::obsolete() {
    core::hide_trace
    [[ ! "$1" ]] && { 
        core::warn "Missing obsolete function name."
        return
    }
    [[ ! "$2" ]] && {
        core::warn "Missing replacement function name."
        return
    }
    core::show_trace

    __print_log yellow "obsolete call to '$1', replace with '$2'"
    return 101
}

obsolete() {
    # shellcheck disable=SC2139
    alias "$1"="core::obsolete '$1' '$2'; $2"
}

alias warn='core::obsolete warn core::warn; core::warn'
alias error='core::obsolete error core::error; core::error'

# Export basic logging functions
export -f core::warn core::error core::info __print_log core::trace