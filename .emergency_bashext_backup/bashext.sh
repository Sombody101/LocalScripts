#!/bin/bash

NULL=/dev/null
alias grep='grep --color=auto'

newnav() {
    : ".BACKUPS: newnav"

    [[ ! "$1" ]] && {
        warn No arguments provided
        return 1
    }

    [[ ! "$2" ]] && {
        warn No path provided
        return 1
    }

    local name=$1
    local path=$2
    shift 2

    eval "
    $name() {
        cd \"$path\"/\$(pathify \$*) || warn \"Failed to locate \$(pathify \$*)\";
    }
    "
}

occ() {
    : ".BACKUPS: occ"
    while :; do
        form -a "$@"
    done
}

pathify() {
    : ".BACKUPS: pathify"
    IFS="/"
    echo "$*"
    unset IFS
}

warn() {
    : ".BACKUPS: warn"
    echo -ne "$(trace): $(red)$*$(norm)\n"
}

addPath() {
    : ".BACKUPS: addPath"
    [[ ! "$1" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! "$PATH" =~ $1 ]] && export PATH="$1:$PATH"
}

showpath() {
    : ".BACKUPS: showPath"
    tr ':' '\n' <<<"$PATH"
}

BACKS="$DRIVE/.BACKUPS/.LOADER"
[ -v EMERGENCY_SD_VERSION ] && BACKS="$HOME/LocalScripts/.emergency_bashext_backup"
CST="$BACKS/cstools"
CST_M="$CST/cstools.main.sh"
ST="$BACKS/site-tools/site-tools.sh"
GC="$BACKS/git-cmds/git_cmds.sh"
APPS="$BACKS/.apps"

qunalias() { unalias "$1" 2>$NULL; }

# Support issues with pre-summer devices (requires unalias)
qunalias drive
qunalias home
qunalias main
newnav backs "$BACKS"
newnav drive "$DRIVE"
newnav home "$HOME"
newnav main "/"
newnav cst "$CST"
newnav ... "$DRIVE/..."

alias clrhist='> $HOME/.bash_history'

# Set the namespace
setspace "$BACKS"

using "command_parser.sh"
using "utils.sh"
using "backup_manager/backup.sh"
#using "$BACKS/.EXTRAS.sh"
regnload "$BACKS/.extras.sh (Unused)"
using "tsklist/TASKLIST.sh"
using "$CST_M"
using "$GC" # -f # The file gets sourced, but using logs a "File Not Found" error, so -f
using "$ST"
using "showcase.sh"

[ ! -v emergency_backup_version ] && {
    EBG="$BACKS/.emergency_backup_module/"
    using "$EBG/.emergency_backup_generator.sh"
}

# Reset namespace
setspace

addPath "$DRIVE/.BACKUPS/.LOADER/bin"
[ -d "$APPS" ] && {
    addPath "$APPS"
    regload "bin.apps ($DRIVE)"
}

# Cleanup
unset newNav qunalias

vs() {
    : ".BACKUPS: vs"
    local inp="$*"
    [[ "$inp" == "" ]] && inp="."
    (code "$inp" &)
}

# Register file
regload "$BACKS/bashext.sh"