#!/bin/bash
# This version of .bashrc was designed with WSL (Windows Sub-system for Linux) in mind.
# It will boot on other versions of bash, but some commands will not work.

FILE=".loader.bashrc"

# Determine machine
[ -v WSL_DISTRO_NAME ] && WSL=TRUE
case $(hostname) in
*"School") sdev=TRUE ;;  # School laptop
"DESKTOP"*) hdev=TRUE ;; # Home PC
"server") server=TRUE ;; # Server
"rasp"*) server=TRUE ;;  # RaspberryPi
*) unknown=TRUE ;;       # Anything else
esac

# Security
LockDevice() {
    : "$FILE: LockDevice"

    clear
    trap : SIGINT
    : >"$HOME/.DEVICE_LOCKED"
    echo -ne "\e[31mDont use computers that arent yours\n"
    while :; do
        [[ $(read -r) == "Device::Unlock" ]] && {
            echo -ne "\e[32mWelcome back\n"
            break
        }

        clear
        echo -ne "\e[31mDont use computers that arent yours\n"
    done

    rm "$HOME/.DEVICE_LOCKED"
}
[ -f "$HOME/.DEVICE_LOCKED" ] && LockDevice

[ -f "$HOME/.wget-hsts" ] && rm "$HOME/.wget-hsts"

[ ! -f "$HOME/ACTIVE_UI" ] && {
    echo "No ACTIVE_UI : Creating one (UBUNTU)"
    echo "UBUNTU" >"$HOME/ACTIVE_UI"
}

warn() {
    : "$FILE: warn [TEMPORARY]"
    echo "$(red)$*$(norm)"
}

if [[ $(cat "$HOME/ACTIVE_UI") == "KALI" ]]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1
    PROMPT_ALTERNATIVE=twoline
    NEWLINE_BEFORE_PROMPT=yes

    prompt_color='\[\033[;32m\]'
    info_color='\[\033[1;34m\]'
    prompt_symbol=㉿
    if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
        prompt_color='\[\033[;94m\]'
        info_color='\[\033[1;31m\]'
        # Skull emoji for root terminal
        prompt_symbol=💀
    fi
    case "$PROMPT_ALTERNATIVE" in
    twoline)
        PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_color')}('$info_color'\u'$prompt_symbol'\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] '
        ;;
    oneline)
        PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ '
        ;;
    backtrack)
        PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        ;;
    esac
    unset prompt_color
    unset info_color
    unset prompt_symbol
elif [[ $(cat $HOME/ACTIVE_UI) == "UBUNTU" ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

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

# Set search dir:
# USING_DIR=
using() {
    : ".loader.bashrc: using"

    local FOUND
    local T_ITEM

    if [[ "$1" != "/"* ]]; then
        for file in "$HOME/LocalScripts/$1"*; do
            if [ -f "$file" ]; then
                source "$file" 2>/dev/null
                FOUND=TRUE
                T_ITEM="$file"
                return 0
            fi
        done
    fi

    [[ $FOUND != TRUE ]] && {
        source "$1" 2>/dev/null && FOUND=TRUE
    }

    [[ $FOUND != TRUE ]] && {
        [[ "$2" != "-f" ]] && warn "Unable to find \"$1\""
    }

    [[ "$2" == "-o" ]] && [[ "$FOUND" == TRUE ]] && {
        echo "$(blue)'$T_ITEM' found [$1]$(norm)."
        return 0
    }
}

ConnectDrives() {
    : "$FILE: ConnectDrives"
    for letter in {a..z}; do
        if [[ -d "/mnt/$letter" ]]; then
            sudo mount -t drvfs "$letter": "/mnt/$letter" &>/dev/null || warn "Unable to mount drive :: NOT_CONNECTED"
        fi
    done
}

MountDrives() {
    : "$FILE: MountDrives"

    # OS check
    [ ! -v WSL ] && {
        warn "!WSL:$WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
        return 1
    }

    [[ -d $DRIVE/.BACKUPS/ ]] && {
        source "$DRIVE/.BACKUPS/.LOADER/.BACKUP.sh"
        return 0
    }

    [[ -d $(cat "$HOME/.active_drive")/.BACKUPS/ ]] && {
        export DRIVE=$(cat "$HOME"/.active_drive)
        source "$DRIVE/.BACKUPS/.LOADER/.BACKUP.sh"
        return 0
    }

    for letter in {a..z}; do
        if [[ -d /mnt/$letter ]]; then
            sudo mount -t drvfs $letter: /mnt/$letter &>/dev/null || echo $(red)Unable to mount drive $letter:\\ :: NOT_CONNECTED
            [[ -d "/mnt/$letter/.BACKUPS/" ]] && DRIVE=/mnt/$letter && break
        fi
    done

    if [[ $DRIVE == "" ]]; then
        export DRIVE=DRIVE_NOT_FOUND
        return 1
    else
        source "$DRIVE/.BACKUPS/.LOADER/.BACKUP.sh"
        echo "$DRIVE" >"$HOME/.active_drive"
        export DRIVE
        return 0
    fi
}

hax() {
    : "$FILE: hax"
    cp -r "$DRIVE/.HackerMan_Assets" "$HOME/LocalScripts" && bash "$HOME/LocalScripts/.HackerMan_Assets/HackermanConsole.sh"
}

compAll() {
    : "$FILE: compAll"
    declare -a platforms=("x86" "x64" "ARM" "ARM64")

    local count=1
    for platform in "${platforms[@]}"; do
        echo "$(magenta)"BUILD: $count"$(norm)"
        local count=$((count + 1))
        local buildPath="bin\Release\publish\\$platform"

        msbuild /p:Configuration=Release /p:Platform="Any CPU" /p:PlatformTarget="$platform" /p:PublishDir="$buildPath" /t:Clean /t:Publish || continue

        [ -d "./bin/AllBinaries" ] || {
            echo "Creating binaries folder..."
            sudo mkdir "./bin/AllBinaries"
        }

        cp "${buildPath//\\/\/}/HynusWynus BackupManager.exe" "${buildPath//\\/\/}/HynusWynus BackupManager$platform.exe"
        cp "${buildPath//\\/\/}/HynusWynus BackupManager$platform.exe" "./bin/AllBinaries/" || warn Failed to copy binary to AllBinaries
    done
}

chckusr() {
    : "$FILE: chckusr"
    u="$@"
    if [[ $u == "" ]]; then
        warn "No arguments provided."
        return
    fi

    echo "$(blue)Checking with method one...$(norm)"
    maigret "$u" || warn "Error checking with method one..."
    echo "$(blue)Checking with method two...$(norm)"
    python3 "$HOME/sherlock/sherlock" "$u" || echo "$(red)Error checking with method two..."
}

newProj() {
    : "$FILE: newProj"
    mkdir "$HOME/cs/$1" && cd "$_"
    dotnet new console
}

showPath() {
    : "$FILE: listPath [TEMPORARY]"
    local tmp=$PATH
    IFS=':'
    read -ra arr <<<"$tmp"
    for item in "${arr[@]}"; do
        echo "$item"
    done
}

alias impPacks='source "$DRIVE/.BACKUPS/.LOADER/.BACKUP.SH" || warn "No drive found : Some commands unavailable"'
export DOTNET_ROOT="$HOME/dotnet"
[[ ! $PATH =~ "$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts" ]] && export PATH="$PATH:$HOME/dotnet:/mnt/c/Users/evans/.platformio/penv/Scripts"

[ -v WSL ] && {
    alias lua='luajit-2.1.0-beta3'
    alias msbuild='/mnt/c/Program\ Files/Microsoft\ Visual\ Studio/2022/Community/MSBuild/Current/Bin/amd64/MSBuild.exe'
}

using ".cmds.sh"
using "$HOME/GitSetup/gitScripts.sh" -f

if [ -v server ] || [ -v unknown ]; then
    # Skip right to loading "emergency" functions (No external media to load from)
    using ".EMERGENCY_SD_SPAWNER.sh"
else
    MountDrives # Assumes this is WSL
    if [[ $DRIVE == "DRIVE_NOT_FOUND" ]] || [[ $DRIVE =~ EMERGENCY ]]; then
        using ".EMERGENCY_SD_SPAWNER.sh"
    fi
fi

DRIVE_BIN="$BACKS/bin"

# Alias all cs projects
for folder in "$HOME/cs/"*; do
    alias "p_${folder//$HOME\/cs\//}"="cd $folder"
done
