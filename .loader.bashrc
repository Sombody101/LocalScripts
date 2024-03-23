#!/bin/bash
# This version of .bashrc was designed with WSL (Windows Sub-system for Linux) in mind.
# It will boot on other versions of bash, but some commands will not work.

# Determine machine
[ -v WSL_DISTRO_NAME ] && WSL=TRUE
case $(hostname) in
*"SchoolLT") export sdev=TRUE ;; # School laptop
*"Q966") export hdev=TRUE ;;     # Home PC
"server") export server=TRUE ;;  # Server
"rasp"*) export server=TRUE ;;   # RaspberryPi
*) unknown=TRUE ;;               # Anything else
esac

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
    echo "$(red)$*$(norm)"
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
alias git='sudo git'
alias dotnet='sudo dotnet'

# Set search dir:
setspace() {
    local path="$*"

    if [[ "$path" == "" ]] || [[ "$path" == "--" ]]; then
        # Reset path
        export __using_path="$HOME/LocalScripts"
        return 0
    fi

    export __using_path="$path"
}

alias getspace='echo "$__using_path"'
setspace "$__using_path" # Reset namespace

using() {
    : ".loader.bashrc: using"

    local file="$1"

    # Check if arg is not an absolute path
    if [[ "$file" != "/"* ]]; then
        local scripts=("$__using_path/$file"*)
        local s_len="${#scripts[@]}"

        if [[ "$s_len" -gt 1 ]]; then
            warn "Found multiple scripts starting with '$file':"
            for item in "${scripts[@]}"; do
                printf '\t%s\n' "$item"
            done

            add_managed_import "$(red)[NOT*F] $(_indigo)atmp_path:$(norm) $file"
            return 1
        fi

        file="${scripts[0]}"
    fi

    if [[ ! -f "$file" ]]; then
        [[ "$2" != "-f" ]] && {
            warn "Unable to find '$file'"
            add_managed_import "$(red)[NOT F] $(_indigo)atmp_path:$(norm) $file"
            return 1
        }

        add_managed_import "$(red)[NOT F] $(magenta)soft_path:$(norm) $file"
        return 1
    fi

    source "$file" 2>"/dev/null"
    add_managed_import "$(blue)[FOUND] $(cyan)full_path:$(norm) $(realpath "$file")"

    if [[ "$2" == "-o" ]]; then
        echo "$(blue)'$file' found [$1]$(norm)"
        return 0
    fi
}
# Won't be listed in 'mimports' as it's seen as a part of 'using'
source "$HOME/LocalScripts/utils/managed_importer.sh"

# using "utils/Colors.sh" # Legacy
using "utils/colors.sh"
using "utils/happytime.sh"
using "utils/text.sh"
using "utils/utils.sh"
using "utils/prompt_setter.sh"
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

    # ExtStorage has never been given a letter lower than G:\, and won't be given one higher than D:\
    for letter in {d..g}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" &>/dev/null || {
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

{ # Variables
    EMERGENCY_LOADER=".emergency_backup_loader.sh"
}

: Check server, unknown, or FORCE_BACKUP
if [ "$server" ] || [ "$unknown" ] || [ "$FORCE_BACKUP" ]; then
    # Skip right to loading "emergency" functions (No external media to load from)
    using "$EMERGENCY_LOADER"
elif track MountDrives; then
    # Assumes this is WSL
    using "$DRIVE/.BACKUPS/.LOADER/bashext.sh"
elif [[ ! "$DRIVE" ]]; then
    using "$EMERGENCY_LOADER"
else
    warn "Failed to import bash-ext (Emergency or from USB)"
fi

export DRIVE_BIN="$BACKS/bin"

force_usb() {
    unset DRIVE BACKS
    ref
}

using "remupd/git-recov.sh"
regload "$HOME/LocalScripts/.loader.bashrc"
