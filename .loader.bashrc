#!/bin/bash

# This version of .bashrc was designed with WSL (Windows Sub-system for Linux) in mind.
# It will boot on other versions of bash, but some commands will not work. I will check for WSL
# before running WSL dependent commands, but I can't gaurentee that is enough.

PS4='#| \[$YELLOW\]$(basename ${BASH_SOURCE} 2>/dev/null):\[$RED\]${LINENO}: \[$(echo -ne "\e[38;2;255;165;0m")\]${FUNCNAME[0]}()\[$NORM\] - \[$CYAN\][${SHLVL},${BASH_SUBSHELL},$?]\[$NORM\]: '

LS="$HOME/LocalScripts"
LAPPS="$LS/.lapps"

# Determine machine
[ -v WSL_DISTRO_NAME ] && export WSL=TRUE
case $(hostname) in
*"SchoolLT") export sdev=TRUE ;; # School laptop
*"Q966") export hdev=TRUE ;;     # Home PC
"server") export server=TRUE ;;  # Server
"rasp"*) export server=TRUE ;;   # RaspberryPi
*) export unknown=TRUE ;;        # Anything else
esac

[[ "$WSL" ]] && [[ ! "$PATH" =~ "/mnt/c/Windows" ]] && {
    # Importand environment variables (VSCode and Windows utilities)
    PATH="$PATH:$LAPPS:/mnt/c/Users/evans/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Windows/system32:/mnt/c/Windows"
}

export PATH

# [[ "$CLEAN_PATH" ]] && {
#     # Cleanup PATH
#     tmp_path=""
#
#     readarray -t tmp_path_arr < <(path.showpath)
#     for dir in "${tmp_path_arr[@]}"; do
#         [[ ! "$dir" =~ ^/mnt/c/.* ]] && tmp_path+="$dir:"
#     done
#
#     export PATH="${tmp_path%:}"
#
#     unset tmp_path tmp_path_arr
# }

core::flag() {
    : "Options: HOME_DEV, MOBILE_DEV, WSL, SERVER, UNKNOWN"
    : "Returns: 0 if all flags are set, 1 otherwise (including unknown flags)"
    local exit_code=0

    for arg in "${@:1}"; do
        case "$arg" in
        "HOME_DEV")
            : "Checking hdev"
            [[ ! "$hdev" ]] && exit_code=1
            ;;
        "SCHOOL_DEV")
            : "Checking sdev"
            [[ ! "$sdev" ]] && exit_code=1
            ;;
        "WSL")
            : "Checking WSL"
            [[ ! "$WSL" ]] && exit_code=1
            ;;
        "SERVER")
            : "Checking server"
            [[ ! "$server" ]] && exit_code=1
            ;;
        "UNKNOWN")
            : "Checking unknown"
            [[ ! "$unknown" ]] && exit_code=1
            ;;
        *)
            core::warn "Unknown flag: $arg"
            exit_code=2
            ;;
        esac
    done

    return $exit_code
}

# Security
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
[ -f "$HOME/.wget-hsts" ] && rm "$HOME/.wget-hsts"

alias ed='sudo nano'
alias drive='[[ $DRIVE != "DRIVE_NOT_FOUND" ]] && cd $DRIVE || core::warn "Drive not found : $DRIVE"'
alias refresh='using .cmds.sh'
alias .cmds.sh='ed $HOME/LocalScripts/.cmds.sh'
alias .bashrc='ed $HOME/.bashrc'
alias .loader='ed $HOME/LocalScripts/.loader.bashrc'

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

source "$LS/utils/managed_importer.sh" # Provides 'using' and import commands

using "utils/.temporary.sh"
using "config/config.sh" -f

core::create_config() {
    [[ -f "$HOME/.lsconfig.sh" ]] && [[ ! "$1" == "-f" ]] && {
        core::warn "Config file already exists at $HOME/.lsconfig.sh"
        return 1
    }

    cp "$LS/config/config.sh" "$HOME/.lsconfig.sh"
    echo "Config created at $HOME/.lsconfig.sh"
}

using "$HOME/.lsconfig.sh" -f  # Import user defined configuration [OPTIONAL]
using "command_registry.sh"    # Module/command registry
using "utils/colors.sh"        # Color variables and aliases
using "utils/happytime.sh"     # A joke command (Figlet)
using "utils/text.sh"          # Provides 'Sprint' and 'array'
using "utils/utils.sh"         # Misc commands for basic operations
using "utils/prompt_setter.sh" # Sets the PS1 prompt (ui)
using "remupd/git-recov.sh"    # Provides 'gitupdate'
using ".cmds.sh"               # VERY old (probably legacy) commands from my days on ChromeOS Embedded Linux

###
#* Mount drive and import BashExt
###

core::mount_drives() {
    : ".loader: core::mount_drives"

    local cached_drive_path uid gid

    # OS check
    [ ! -v WSL ] && {
        core::warn "!WSL: $WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
        return 1
    }

    : Check if DRIVE is for emergency backup
    [[ -f "$DRIVE/backup_version.sh" ]] && {
        return 1 # non zero for second if statement
    }

    : Check if the drive has already been exported, returns if it is
    [[ -d "$DRIVE/.BACKUPS/" ]] && {
        return
    }

    cached_drive_path="$HOME/.active_drive"

    : Check if cached drive path works
    [[ -d $(cat "$cached_drive_path")/.BACKUPS/ ]] && {
        DRIVE="$(cat "$cached_drive_path")"
        export DRIVE
        return
    }

    uid=$(id -u "$USER")
    gid=$(id -g "$USER")

    # ExtStorage has never been given a letter lower than G:\, and won't be given one higher than D:\
    for letter in {d..g}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" -o uid="$uid",gid="$gid",metadata &>/dev/null || {
                core::warn "Unable to mount win drive $letter:\\ :: NOT_CONNECTED"
                continue
            }

            [[ -d "/mnt/$letter/.BACKUPS/" ]] && {
                export DRIVE="/mnt/$letter"
                break
            }
        fi
    done

    if [[ ! "$DRIVE" ]]; then
        return 1
    fi

    export DRIVE
    echo "$DRIVE" >"$cached_drive_path"
}

export DOTNET_ROOT="$HOME/dotnet"
#[[ ! $PATH =~ "$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts" ]] && export PATH="$PATH:$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts"

flag WSL && {
    alias lua='luajit-2.1.0-beta3'
    alias msbuild='/mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/MSBuild/Current/Bin/amd64/MSBuild.exe'
}

# Import bashext.sh
EMERGENCY_LOADER=".emergency_backup_loader.sh"

core::load_source() {
    : "Check server, unknown, or FORCE_BACKUP"

    if [[ "$server" ]] || [[ "$unknown" ]] || [[ "$FORCE_BACKUP" ]]; then
        # Skip right to loading "emergency" functions (No external media to load from)
        using "$EMERGENCY_LOADER"

    elif core::mount_drives; then
        # Assumes this is WSL
        using "$DRIVE/.BACKUPS/.LOADER/bashext.sh"
        unset EMERGENCY_LOADER

    elif [[ "$backup_env" ]] || [[ ! "$DRIVE" ]] || [[ "$DRIVE" =~ "importer.sh"$ ]]; then
        using "$EMERGENCY_LOADER"

    elif [[ ! "$1" ]]; then
        # Remove variables that could block bashext
        unset DRIVE BACKS backup_env emergency_backup_version
        echo "Attempting to switch back to USB-BashExt"
        core::load_source DONT_RECURSE || core::warn "Failed to switch back to USB-BashExt"
    fi
}

# Load bashext (From drive or backup)
core::load_source :

register_module core
export DRIVE_BIN="$BACKS/bin"

regload "$LS/.loader.bashrc"
