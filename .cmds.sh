#!/bin/bash

using "Colors.sh"
using "HappyTime.sh"
using "Text.sh"
using "Utils.sh"

# Source the independant file for each computer if it's there
using "$HOME/.ind.sh" -f

blue
echo -ne 'Imported     '
[[ $(cat $HOME/ACTIVE_UI) == "KALI" ]] && echo
LINE=TRUE
norm

alias ed='sudo nano'
alias .cmds.sh='ed $HOME/LocalScripts/.cmds.sh'
alias .bashrc='ed $HOME/.bashrc'
alias .loader='ed $HOME/LocalScripts/.loader.bashrc'
alias drive='[[ $DRIVE != DRIVE_NOT_FOUND ]] && cd $DRIVE || warn Drive not found : $DRIVE'
alias refresh='using .cmds.sh'

EVANS="/mnt/c/Users/evans/"
alias evans='cd $EVANS'
alias docs='cd $EVANS/OneDrive/Documents/'
alias down='cd $EVANS/Downloads'

back() {
    local arg=${1:-1}
    local dir=""
    while [[ $arg -gt 0 ]]; do
        dir="../$dir"
        ((arg--))
    done
    cd "$dir"
}

warn() {
    echo -ne "$(red)$*$(norm)\n"
}

place() {
    mv $DRIVE/Compressor/compress/bin/Debug/net7.0/win-x64/publish/compress.exe $HOME
    mv $DRIVE/Compressor/decompress/bin/Debug/net7.0/win-x64/publish/decompress.exe $HOME
    mv $HOME/decompress.exe $HOME/decompress
    mv $HOME/compress.exe $HOME/compress
    mv $HOME/decompress $DRIVE_BIN
    mv $HOME/compress $DRIVE_BIN
}

KALI() {
    [[ $(cat $HOME/ACTIVE_UI) == "KALI" ]] && {
        echo Already in KALI
        return
    }
    echo KALI >$HOME/ACTIVE_UI
    exec $SHELL
}

UBUNTU() {
    [[ $(cat $HOME/ACTIVE_UI) == "UBUNTU" ]] && {
        echo Already in UBUNTU
        return
    }
    echo UBUNTU >$HOME/ACTIVE_UI
    exec $SHELL
}

ui() {
    if [[ $ACTIVE_UI == "KALI" ]]; then
        echo "$(blue)$ACTIVE_UI$(norm)"
    else
        printf "\033[38;5;208m%s\033[m\n" "$ACTIVE_UI"
    fi
}
