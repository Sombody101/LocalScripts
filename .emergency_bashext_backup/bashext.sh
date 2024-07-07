#!/bin/bash

NULL=/dev/null
alias grep='grep --color=auto'

# So the PS1 prompt never has colors bleeding from a previous command
export PS1="\[\033[0m\]$PS1"
export PS4='#| \[$YELLOW\]$(basename ${BASH_SOURCE} 2>/dev/null):\[$RED\]${LINENO}: \[$(echo -ne "\e[38;2;255;165;0m")\]${FUNCNAME[0]}()\[$NORM\] - \[$CYAN\][${SHLVL},${BASH_SUBSHELL},$?]\[$NORM\] '

newnav() {
    : ".BACKUPS: newnav"

    local name path

    [[ ! "$1" ]] && {
        warn "No arguments provided"
        return 1
    }

    [[ ! "$2" ]] && {
        warn "No path provided"
        return 1
    }

    name=$1
    path=$2
    shift 2

    eval "$name() {
    local path=\"\$(path.pathify \"\$*\")\"
    cd \"$path\"/\$path || warn \"Failed to locate \$path\";
}"
}

BACKS="$DRIVE/.BACKUPS/.LOADER"
[[ "$backup_env" ]] && BACKS="$LS/.emergency_bashext_backup"

export BACKS

CST="$BACKS/cstools"
CST_M="$CST/cstools.main.sh"
ST="$BACKS/site-tools/site-tools.sh"
#GC="$BACKS/git-cmds/git_cmds.sh"
APPS="$BACKS/.apps"
LAPPS="$LS/.lapps"

# Quiet Un-Alias
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

alias clrhist='> $HOME/.bash_history'

# Set the namespace
setspace "$BACKS"

using "command_parser.sh"
using "utils.sh"
using "debugging/verbose.sh"
# I don't really use this since I started to use GitHub, so there's no reason importing such a large file
#using "backup_manager/backup.sh"
regnload "$BACKS/.extras.sh (Unused)"
using "tsklist/TASKLIST.sh"
using "$CST_M"
#using "$GC" # -f # The file gets sourced, but using logs a "File Not Found" error, so -f
using "$ST"
using "showcase.sh"

# Import EmergencyBackupGenerator if not currently using a backup
[[ ! "$backup_env" ]] && {
    EBG="$BACKS/.emergency_backup_module/"
    using "$EBG/.emergency_backup_generator.sh"
}

# Reset namespace
setspace

app.loadall() {
    cp "$APPS/"* "$LAPPS"
}

app.add() {
    [[ ! "$*" ]] && {
        warn "No app provided"
        return 1
    }

    [[ ! -f "$*" ]] && {
        warn "Failed to find app '$*'"
        return 1
    }

    sudo cp -p "$*" "$APPS"
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
    (code "${*:-.}")
}

# Register file
regload "$BACKS/bashext.sh"
