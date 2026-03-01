#!/bin/bash

[[ "$DEBUG" ]] && set -x

# Print all ':' statements (usually used for debug lines only visible in with set-x)
# PRINT_DEBUG_LINES=true

# So the prompt never has colors bleeding from a previous command
export PS1="\[\033[0m\]$PS1"
export PS4='#| \[$YELLOW\]$(basename ${BASH_SOURCE} 2>/dev/null):\[$RED\]${LINENO}: \[$(echo -ne "\e[38;2;255;165;0m")\]${FUNCNAME[0]}()\[$NORM\]:\[$CYAN\][${SHLVL},${BASH_SUBSHELL},$?]\[$NORM\]: '
#export PS4='\[${BLUE}\]$(printf "[%s] @%s " $(date +%T) $LINENO)\[${NORM}\]'
#export PS4='\[$NORM\]# $(basename ${BASH_SOURCE}):${LINENO}: ${FUNCNAME}(): '

LS="$(dirname "${BASH_SOURCE[0]}")"
LAPPS="$LS/bin"

# Disable variable escaping in shell
shopt -s direxpand

# Determine machine
[ -v WSL_DISTRO_NAME ] && export WSL=TRUE
case $(hostname) in
*"SchoolLT") export sdev=TRUE ;; # School laptop
*"Desktop") export hdev=TRUE ;;  # Home PC
"server") export server=TRUE ;;  # Server
"rasp"*) export server=TRUE ;;   # RaspberryPi
*) export unknown=TRUE ;;        # Anything else
esac

[[ "$WSL" && ! "$PATH" =~ "/mnt/c/Windows" ]] && {
    # Important environment variables (VSCode and Windows utilities)
    PATH="$PATH:/mnt/c/Users/evans/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Windows/system32:/mnt/c/Windows"
}

# Include .lapps in PATH
[[ ! "$PATH" =~ $LAPPS ]] && {
    PATH="$PATH:$LAPPS"
}

export PATH

# Provides all "core" functions (warn, error, trace, etc)
# shellcheck disable=SC1091
source "$LS/core.sh"

# This is just something I added when I started learning bash.
# It's genuinely useless, but I like it.
core::lock_device() {
    : ".loader: LockDevice"

    clear
    trap : SIGINT
    echo -ne "$RANDOM:$RANDOM:$RANDOM@$RANDOM\t\t\t--\r\n-DFF" >"$HOME/.bash.sysloader.o"
    while :; do
        echo -e "\e[31mDont use computers that arent yours"
        read -r res
        [[ "$res" == "Device::Unlock" ]] && {
            echo -e "\e[32mWelcome back"
            break
        }

        clear
    done

    rm "$HOME/.bash.sysloader.o"
}
[ -f "$HOME/.bash.sysloader.o" ] && core::lock_device

# I use wget randomly, but don't need it to remember anything about my sessions.
[ -f "$HOME/.wget-hsts" ] && rm "$HOME/.wget-hsts"

[[ "$PRINT_DEBUG_LINES" ]] && {
    :() { echo "$*" >&2; }
}

alias ed='nano'
alias drive='[[ $DRIVE != "DRIVE_NOT_FOUND" ]] && cd $DRIVE || core::warn "Drive not found : $DRIVE"'
# This is obsolete and was used before the whole "Local Scripts" library. It's still here for legacy installations.
alias refresh='using .cmds.sh'
alias .cmds.sh='ed $LS/.cmds.sh'
alias .bashrc='ed $HOME/.bashrc'
alias .loader='ed $LS/.loader.bashrc'

# Very new. Not all machines will have this installed, but use it if it is.
which -s eza && alias ls='eza'

alias ll='ls -l'
alias l='ls -CF'
alias c='clear'
alias a='ls -a'
alias ca='c;a'
alias cl='c;ls'
alias la='ls -CFa'
alias home='cd $HOME/'
alias main='cd /'
alias ref='exec $SHELL'

###
#* Main imports
###

# Verify .lapps/flag works
if ! command -v flag >/dev/null; then
    core::warn "Failed to find flag command (compilation may be required). Defaulting to core::flag"
    using "utils/fallback_flags"
    alias flag='core::flag'
fi

flag any SERVER UNKNOWN && emergency_backup_version="$(git -C $LS log -1 --format='%ad' --date=format:'%m.%d.%Y')"

source "$LS/utils/managed_importer.sh" # Provides 'using' and import commands

# Colors needs to come _after_ the registry as colors is a module, so swapping them leads to a missing command error.
using "command_registry.sh"
using "utils/colors.sh"

using "utils/.temporary.sh"

using "config/config.sh" -f
core::create_config() {
    [[ -f "$HOME/.lsconfig.sh" && ! "$1" == "-f" ]] && {
        core::warn "Config file already exists at $HOME/.lsconfig.sh"
        return 1
    }

    cp "$LS/config/config.sh" "$HOME/.lsconfig.sh"
    echo "Config created at $HOME/.lsconfig.sh"
}

using "$HOME/.lsconfig.sh" -f # Import user defined configuration [OPTIONAL]
using "debugging/debug_root.sh"

[[ "$DEBUG" ]] && debug # Enable environment debugging

using "utils/happytime.sh"     # A joke command (Figlet)
using "utils/text.sh"          # Provides 'Sprint' and 'array'
using "utils/utils.sh"         # Misc commands for basic operations
using "utils/prompt_setter.sh" # Sets the PS1 prompt (ui)
using "remupd/git-recov.sh"    # Provides 'gitupdate'
using ".cmds.sh"               # VERY old (probably legacy) commands from my days on ChromeOS Embedded Linux

###
#* Mount drive and import BashExt
###

# shellcheck disable=SC2120
core::mount_drives() {
    : ".loader: core::mount_drives"

    # OS check
    ! flag WSL && {
        core::warn "!WSL: $WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
        return 1
    }

    ! sudo -n true && {
        : "Sudo not available. Skipping drive mount."
        return 1
    }

    uid=$(id -u "$USER")
    gid=$(id -g "$USER")

    for letter in {a..z}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" -o uid="$uid",gid="$gid",metadata &>/dev/null || {
                core::warn -s "${letter^}:\\ not mounted on Windows :: Cannot mount to /mnt/$letter [$?]"
                : "Unable to mount win drive $letter:\\ :: NOT_CONNECTED"
                continue
            }

            [[ -d "/mnt/$letter/.BACKUPS" ]] && export DRIVE="/mnt/$letter"
        fi
    done
}

flag WSL && {
    export DOTNET_ROOT="$HOME/.dotnet"
    export DOTNET_CLI_TELEMETRY_OPTOUT="true"
    export BROWSER="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"

    core::mount_drives
}

using "bashext/bashext.sh"

flag WSL && {
    path.add '/mnt/c/rsl/platform-tools'
    path.add "$DOTNET_ROOT:$DOTNET_ROOT/tools:$HOME/.local/bin"
    _tmp_vspath=$(path.towsl 'C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\IDE')
    [[ -d $_tmp_vspath ]] && path.add "$_tmp_vspath"
    alias vsx='devenv.exe'

    unset _tmp_vspath
}

# Load bashext (From drive or backup)
# EMERGENCY_LOADER=".emergency_backup_loader.sh" core::load_source :

register_module core
export DRIVE_BIN="$BACKS/bin"

regload "$LS/.loader.bashrc"

[[ "$1" == "install" ]] && {
    # shellcheck disable=SC1091
    source "./install.sh" "$2"
}

# Binary characters keep appearing in my main PCs history file.
flag HOME && [[ "$(file -b ~/.bash_history)" == "data" ]] && {
    : "Cleaning bash history"
    cat ~/.bash_history | col -b >~/.bash_history.spare
    mv ~/.bash_history.spare ~/.bash_history
}

[[ "$DEBUG" ]] && set +x

return 0 # Mask return if there was no debug variable
