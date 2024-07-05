#!/bin/bash

# This version of .bashrc was designed with WSL (Windows Sub-system for Linux) in mind.
# It will boot on other versions of bash, but some commands will not work.

LS="$HOME/LocalScripts"

: Imports configs
source "$LS/cfg/config.sh"

# Determine machine
[ -v WSL_DISTRO_NAME ] && WSL=TRUE
case $(hostname) in
*"SchoolLT") export sdev=TRUE ;; # School laptop
*"Q966") export hdev=TRUE ;;     # Home PC
"server") export server=TRUE ;;  # Server
"rasp"*) export server=TRUE ;;   # RaspberryPi
*) unknown=TRUE ;;               # Anything else
esac

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

flag() {
    : "Options: HOME_DEV, MOBILE_DEV, WSL, SERVER, UNKNOWN"
    : "Returns: 0 if all flags are set, 1 otherwise (including unknown flags)"
    local exit_code=0 # Initialize exit code to success (0)

    # Loop through arguments starting from the second (skip script name)
    for arg in "${@:2}"; do
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
            warn "Unknown flag: $arg"
            exit_code=2
            ;;
        esac
    done

    return $exit_code
}

# Security
LockDevice() {
    : ".loader: LockDevice"

    clear
    trap : SIGINT
    echo -ne "$RANDOM:$RANDOM:$RANDOM@$RANDOM\t\t\t--\r\n-DFF" >"$HOME/.bash.sysloader.o"
    while :; do
        echo -ne "\e[31mDont use computers that arent yours\n"
        read -r res
        [[ "$res" == "Device::Unlock" ]] && {
            echo -ne "\e[32mWelcome back\n"
            break
        }

        clear
    done

    rm "$HOME/.bash.sysloader.o"
}
[ -f "$HOME/.bash.sysloader.o" ] && LockDevice

[ -f "$HOME/.wget-hsts" ] && rm "$HOME/.wget-hsts"

help() {
    if [[ "$1" == "me" ]]; then
        echo "No"
        return 0
    fi

    command help
}

warn() {
    : ".loader: warn [TEMPORARY]"
    echo "$RED$*$NORM"
}

alias ll='ls -l'
alias l='ls -CF'

alias c='clear'
alias a='ls -a'
alias ca='c;a'
alias la='ls -CFa'
alias home='cd $HOME/'
alias main='cd /'
alias downloads='cd /mnt/c/Users/evans/Downloads'
alias ref='exec $SHELL'
alias cs='cd $HOME/cs'
alias aform='form -a'
#alias git='sudo git'
#alias dotnet='sudo dotnet'

# Set search dir:
setspace() {
    local path="$*"

    if [[ ! "$path" ]] || [[ "$path" == "--" ]]; then
        # Reset path
        export __using_path="$LS"
        return 0
    fi

    export __using_path="$path"
}

alias getspace='echo "$__using_path"'
setspace "$__using_path" # Reset namespace

using() {
    : ".loader.bashrc: using"
    : "<file path> <option>"
    : "-f: Hide errors"
    : "-o: Verbose info"

    local file="$1"

    # Check if arg is not an absolute path
    if [[ "$file" != "/"* ]]; then
        local scripts=("$__using_path/$file"*)
        local s_len="${#scripts[@]}"

        if [[ "$s_len" -gt 1 ]]; then

            # More than one script found with this name (or prefix)

            warn "Found multiple scripts starting with '$file':"
            for item in "${scripts[@]}"; do
                printf '\t%s\n' "$item"
            done

            add_managed_import 2 "$(_indigo)atmp_path:$NORM $file"
            return 1
        fi

        file="${scripts[0]}"
    fi

    if [[ ! -f "$file" ]]; then
        [[ "$2" != '-f' ]] && {
            warn "Unable to find '$file'"
            add_managed_import 1 "$(_indigo)atmp_path:$NORM $file"
            return 1
        }

        add_managed_import 1 "${MAGENTA}soft_path:$NORM $file"
        return 1
    fi

    add_managed_import 0 "${CYAN}full_path:$NORM $(realpath "$file")"

    if ! source "$file"; then
        add_managed_import "$RED" "ERROR" "${RED}full_path:$NORM $(realpath "$file")"
    fi

    if [[ "$2" == '-o' ]]; then
        echo "$BLUE'$file' found [$1]$NORM"
        return 0
    fi
}
# Won't be listed in 'mimports' as it's seen as a part of 'using'
source "$LS/utils/managed_importer.sh"

# using "utils/Colors.sh" # Legacy
using "command_registry.sh"
using "utils/colors.sh"
using "utils/happytime.sh"
using "utils/text.sh"
using "utils/utils.sh"
track using "utils/prompt_setter.sh"
using ".cmds.sh"

MountDrives() {
    : ".loader: MountDrives"

    # OS check
    [ ! -v WSL ] && {
        warn "!WSL: $WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
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

    local cached_drive_path="$HOME/.active_drive"

    : Check if cached drive path works
    [[ -d $(cat "$cached_drive_path")/.BACKUPS/ ]] && {
        export DRIVE="$(cat "$cached_drive_path")"
        return
    }

    local uid=$(id -u "$USER")
    local gid=$(id -g "$USER")

    # ExtStorage has never been given a letter lower than G:\, and won't be given one higher than D:\
    for letter in {d..g}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" -o uid="$uid",gid="$gid",metadata &>/dev/null || {
                warn "Unable to mount win drive $letter:\\ :: NOT_CONNECTED"
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

showPath() {
    : ".loader: listPath [TEMPORARY]"
    local tmp=$PATH
    IFS=':'

    read -ra arr <<<"$tmp"
    for item in "${arr[@]}"; do
        echo "$item"
    done
}

# Import-Packages
impacks() {
    local updstr=
    updstr="$(red)<=== Content Refreshed ===>$(norm)"
    regload "$updstr"

    using "$BACKS/bashext.sh"
}

export DOTNET_ROOT="$HOME/dotnet"
#[[ ! $PATH =~ "$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts" ]] && export PATH="$PATH:$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts"

[ -v WSL ] && {
    alias lua='luajit-2.1.0-beta3'
    alias msbuild='/mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/MSBuild/Current/Bin/amd64/MSBuild.exe'
}

# Import bashext.sh
EMERGENCY_LOADER=".emergency_backup_loader.sh"

__load_src() {
    : Check server, unknown, or FORCE_BACKUP
    if [ "$server" ] || [ "$unknown" ] || [ "$FORCE_BACKUP" ]; then
        # Skip right to loading "emergency" functions (No external media to load from)
        using "$EMERGENCY_LOADER"
    elif MountDrives; then
        # Assumes this is WSL
        using "$DRIVE/.BACKUPS/.LOADER/bashext.sh"
        unset EMERGENCY_LOADER
    elif [[ ! "$DRIVE" ]]; then
        using "$EMERGENCY_LOADER"
    else
        [[ ! "$1" ]] && {
            # Remove variables that could block bashext
            unset DRIVE BACKS backup_env emergency_backup_version
            echo "Attempting to switch back to USB-BashExt"
            __load_src DONT_RECURSE || warn "Failed to switch back to USB-BashExt"
        }
    fi
}

# Load bashext (From drive or backup)
__load_src

export DRIVE_BIN="$BACKS/bin"

using "remupd/git-recov.sh"
regload "$LS/.loader.bashrc"

unset __src
