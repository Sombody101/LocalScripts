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
    [[ ! -d "$1" ]] && return 1
    echo "$1"/*
}

BACKS="$LS/bashext"
[[ "$backup_env" ]] && BACKS="$LS/.emergency_bashext_backup"

export BACKS

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

using -space "$BACKS"
using "commanderr/command_parser.sh"
using "utils.sh"
using "winalias.sh"
using "debugging/verbose.sh"
#using "backup_manager/backup.sh"
using "adbutils.sh"
using "showcase.sh"
using "debugging/prof.sh"

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

    cmdchk codium && { (codium "$file_path"); return; }
    cmdchk code && { (code "$file_path"); return; }
    [[ -d "$file_path" ]] && { 
        core::error "No valid editor path found, and given path is a directory. nano fallback will not work."
        return; 
    }
}

regload "$BACKS/bashext.sh"

[[ "$DEBUG_EXT" && ! "$DEBUG_LOADER" ]] && set +x

# Stops the script from returning false if the debug check fails
true
