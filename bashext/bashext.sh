#!/bin/bash

[[ "$DEBUG_EXT" ]] && set -x

alias grep='grep --color=auto'

newnav() {
    core::hide_trace
    : "bashext: newnav"

    [[ ! "$1" ]] && {
        core::warn "No arguments provided"
        return 1
    }

    [[ ! "$2" ]] && {
        core::warn "No path provided for '$1'"
        return 1
    }

    local name
    name=$1

    shift

    eval "$name() { \
        local path=\"\$(path.pathify \"$*\" \"\$*\")\"; \
        cd \"\$path\" || core::warn \"Failed to locate \$path\"; \
    }"

    # command -v complete &>/dev/null && {
    #     complete -F __nav_autocomplete "$name"
    # }
}

__nav_autocomplete() {
    core::hide_trace
    : "bashext: __nav_autocomplete"
    [[ ! -d "$1" ]] && return 1
    echo "$1"/*
}

BACKS="$LS/bashext"
[[ "$backup_env" ]] && BACKS="$LS/.emergency_bashext_backup"

export BACKS

CST="$BACKS/cstools"
CST_M="$CST/cstools.main.sh"
ST="$BACKS/site-tools/site-tools.sh"

# Quiet Un-Alias
qunalias() { unalias "$1" 2>/dev/null; }

# Support issues with pre-summer devices (requires unalias)
qunalias drive
qunalias home
qunalias main
newnav backs "$BACKS"
flag WSL && newnav drive "$DRIVE"
newnav home "$HOME"
newnav main "/"
newnav cst "$CST"

using -space "$BACKS"
using "commanderr/command_parser.sh"
using "utils.sh"
using "winalias.sh"
using "debugging/verbose.sh"
#using "backup_manager/backup.sh"
using "tsklist/TASKLIST.sh"
using "$CST_M"
using "$ST"
using "adbutils.sh"
using "showcase.sh"

flag WSL && {
    newnav apps "/mnt/d/AppsIWillNeverFinish/"
    using "gitutils.sh"
}

# Reset namespace
setspace

# Cleanup
unset qunalias

vs() {
    : "bashext: vs"
    local file_path="${*:-.}"

    # No VSCode, so use Nano
    [[ ! "$(which code)" ]] && {
        ed "$file_path"
        return $?
    }

    (code "$file_path")
}

# Register file
regload "$BACKS/bashext.sh"

[[ "$DEBUG_EXT" && ! "$DEBUG_LOADER" ]] && set +x

# Stops the script from returning false if the debug check fails
true
