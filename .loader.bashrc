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

_help() {
    [[ "$1" == "me" ]] && echo "No" && return 0
    command help
}

help() {
    if [[ "$1" == "me" ]]; then
        echo "No"
        return 0
    fi

    command help
}

LOADED=()

regload() {
    LOADED+=("[$(magenta)+$(norm)]:  $*")
}

regnload() {
    LOADED+=("[$(red)-$(norm)]:  $*")
}

alias loaded='array LOADED'

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

            MANAGED_LOADED+=("$(red)[NOT*F]$(norm) $(bold)$(_indigo)atmp_path:$(norm) $file")
            return 1
        fi

        file="${scripts[0]}"
    fi

    if [[ ! -f "$file" ]]; then
        [[ "$2" != "-f" ]] && {
            warn "Unable to find '$file'"
            MANAGED_LOADED+=("$(red)[NOT F]$(norm) $(bold)$(_indigo)atmp_path:$(norm) $file")
        }

        MANAGED_LOADED+=("$(red)[NOT F]$(norm) $(bold)$(magenta)soft_path:$(norm) $file")
        return 1
    fi

    source "$file" 2>"/dev/null"
    MANAGED_LOADED+=("$(blue)[FOUND]$(norm) $(bold)$(cyan)full_path:$(norm) $(realpath "$file")")

    if [[ "$2" == "-o" ]]; then
        echo "$(blue)'$file' found [$1]$(norm)"
        return 0
    fi
}
# Won't be listed in 'mimports' as it's seen as a part of 'using'
source "$HOME/LocalScripts/utils/managed_importer.sh"

using "utils/Colors.sh"
using "utils/HappyTime.sh"
using "utils/Text.sh"
using "utils/Utils.sh"
using "utils/prompt_setter.sh"
using "$HOME/GitSetup/gitScripts.sh" -f
using ".cmds.sh"

ConnectDrives() {
    : ".loader: ConnectDrives [OBSOLETE]"

    warn ".loader: ConnectDrives is obsolete, use MountDrives instead"

    for letter in {a..z}; do
        if [[ -d "/mnt/$letter" ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" &>/dev/null || warn "Unable to mount drive :: NOT_CONNECTED"
        fi
    done
}

MountDrives() {
    : ".loader: MountDrives"

    # OS check
    [ ! -v WSL ] && {
        warn "!WSL:$WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
        return 1
    }

    local cached_drive_path="$HOME/.active_drive"

    # Assumes drive has already been exported
    [[ -d "$DRIVE/.BACKUPS/" ]] && {
        local pth=
        pth=$(cat "$cached_drive_path")

        sudo mount -t drvfs "${pth:-1}": "$pth" &>/dev/null && {
            export DRIVE="$pth"
            return 0;
        }
    }

    # Check if cached drive path works
    [[ -d $(cat "$cached_drive_path")/.BACKUPS/ ]] && {
        export DRIVE="$(cat "$HOME"/.active_drive)"
        return 0
    }

    # ExtStorage has never been given a letter lower than G:\, and won't be given one higher than D:\
    for letter in {d..g}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" &>/dev/null || {
                warn "Unable to mount win drive $letter:\\ :: NOT_CONNECTED"
                continue
            }

            [[ -d "/mnt/$letter/.BACKUPS/" ]] && {
                DRIVE="/mnt/$letter"
                break
            }
        fi
    done

    export DRIVE
    if [[ ! "$DRIVE" ]]; then
        return 1
    else
        echo "$DRIVE" >"$cached_drive_path"
        return 0
    fi
}

hax() {
    : ".loader: hax"
    cp -r "$DRIVE/.HackerMan_Assets" "$HOME/LocalScripts" && bash "$HOME/LocalScripts/.HackerMan_Assets/HackermanConsole.sh"
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
    updstr="$(red)<=== Content Refreshed  ===>$(norm)"
    regload "$updstr"

    using "$DRIVE/.BACKUPS/.LOADER/bashext.sh"
}

export DOTNET_ROOT="$HOME/dotnet"
#[[ ! $PATH =~ "$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts" ]] && export PATH="$PATH:$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts"

[ -v WSL ] && {
    alias lua='luajit-2.1.0-beta3'
    alias msbuild='/mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/MSBuild/Current/Bin/amd64/MSBuild.exe'
}

# Import bashext.sh
if [ -v server ] || [ -v unknown ]; then
    # Skip right to loading "emergency" functions (No external media to load from)
    using ".EMERGENCY_SD_SPAWNER.sh"
else
    if MountDrives; then # Assumes this is WSL
        using "$DRIVE/.BACKUPS/.LOADER/bashext.sh"
    elif [[ "$DRIVE" ]] || [[ "$DRIVE" =~ "EMERGENCY" ]]; then
        using ".EMERGENCY_SD_SPAWNER.sh"
    fi
fi

export DRIVE_BIN="$BACKS/bin"

# Alias all cs projects
for folder in "$HOME/cs/"*; do
    alias "p_${folder//$HOME\/cs\//}"="cd $folder"
done

using "remupd/git-recov.sh"
regload "$HOME/LocalScripts/.loader.bashrc"