#!/bin/bash

[[ "$DEBUG_EXT" ]] && set -x

alias grep='grep --color=auto'

newnav() {
    : ".BACKUPS: newnav"

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
}

BACKS="$LS/bashext"
[[ "$backup_env" ]] && BACKS="$LS/.emergency_bashext_backup"

export BACKS

CST="$BACKS/cstools"
CST_M="$CST/cstools.main.sh"
ST="$BACKS/site-tools/site-tools.sh"
APPS="$BACKS/.apps"

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

flag WSL && {
    newnav apps "/mnt/d/AppsIWillNeverFinish/"

    token() {
        [[ "$backup_env" ]] && {
            core::warn "Tokens are not available in a backup environment."
            return
        }

        [[ ! "$1" ]] && {
            core::error "No token name supplied"
            return
        }

        ! cat "$DRIVE"/z-?????/"$1".to? 2>/dev/null && core::error "No token file '$1' found."
    }
}

clrhist() { : >"$HOME/.bash_history"; }

# Set the namespace
using -space "$BACKS"

using "commanderr/command_parser.sh"
using "utils.sh"
using "debugging/verbose.sh"
#using "backup_manager/backup.sh"
using "tsklist/TASKLIST.sh"
using "$CST_M"
using "$ST"
using "javautils.sh"
using "showcase.sh"

# Import EmergencyBackupGenerator if not currently using a backup
# [[ ! "$backup_env" ]] && {
#     EBG="$BACKS/.emergency_backup_module/"
#     using "$EBG/.emergency_backup_generator.sh"
# }

# Reset namespace
setspace

app.loadall() {
    cp "$APPS/"* "$LAPPS"
}

app.add() {
    [[ ! "$*" ]] && {
        core::warn "No app provided"
        return
    }

    [[ ! -f "$*" ]] && {
        core::warn "Failed to find app '$*'"
        return
    }

    cp -p "$*" "$APPS"
    echo "App loaded into be.apps"
}

register_module app

[[ ! -d "$LAPPS" ]] && {
    echo "Creating ls.apps"
    loadapps
}

path.add "$BACKS/.apps"
regload "be.apps ($BACKS)"

path.add "$LAPPS"
regload "ls.lapps ($LS)"

# Cleanup
unset qunalias

vs() {
    : ".BACKUPS: vs"
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
