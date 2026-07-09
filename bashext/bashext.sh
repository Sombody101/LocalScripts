#!/bin/bash

[[ "$DEBUG_EXT" ]] && set -x

alias grep='grep --color=auto'

newnav() {
    core::hide_trace
    local name="$1" path="$2"

    [[ ! "$name" ]] && {
        core::error "No arguments provided"
        return
    }

    [[ ! "$path" ]] && {
        core::error "No path provided for nav '$1'"
        return
    }

    eval "$name() { \
        local path=\"\$(path.pathify \"$path\" \"\$*\")\"; \
        cd \"\$path\" || core::warn \"Failed to locate \$path\"; \
    }" || core::error "Failed to generate nav for '$name'. path: $path"
}

__nav_autocomplete() {
    core::hide_trace
    [[ ! -d "$1" ]] && return 1
    echo "$1"/*
}

BACKS="$LS/bashext"
[[ "$backup_env" ]] && BACKS="$LS/.emergency_bashext_backup"

export BACKS

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
