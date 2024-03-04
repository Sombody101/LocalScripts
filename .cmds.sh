#!/bin/bash

# Source the independant file for each computer if it's there
using "$HOME/.ind.sh" -f

blue
echo -ne 'Imported     '
[[ $(cat "$HOME/..ACTIVE_UI" 2>/dev/null) == "KALI" ]] && echo
LINE=TRUE
norm

# Register script file
loaded "$HOME/LocalScripts/.cmds.sh"

alias ed='sudo nano'
alias drive='[[ $DRIVE != "DRIVE_NOT_FOUND" ]] && cd $DRIVE || warn "Drive not found : $DRIVE"'
alias refresh='using .cmds.sh'
alias .cmds.sh='ed $HOME/LocalScripts/.cmds.sh'
alias .bashrc='ed $HOME/.bashrc'
alias .loader='ed $HOME/LocalScripts/.loader.bashrc'

EVANS="/mnt/c/Users/evans/"
alias evans='cd $EVANS'
alias docs='cd $EVANS/OneDrive/Documents/'
alias down='cd $EVANS/Downloads'

back() {
    : ".cmds.sh: back"
    local arg=${1:-1}
    local dir=""
    while [[ $arg -gt 0 ]]; do
        dir="../$dir"
        ((arg--))
    done
    cd "$dir"
}


KALI() {
    : ".cmds.sh: KALI"
    [[ "$ACTIVE_UI" == "KALI" ]] && {
        echo "Already in KALI"
        return
    }
    
    echo "KALI" >"$ACTIVE_UIP"
    ref
}

UBUNTU() {
    : ".cmds.sh: UBUNTU"
    [[ "$ACTIVE_UI" == "UBUNTU" ]] && {
        echo "Already in UBUNTU"
        return
    }

    echo "UBUNTU" >"$ACTIVE_UIP"
    ref
}

ui() {
    : ".cmds.sh: ui"
    if [[ "$ACTIVE_UI" == "KALI" ]]; then
        echo "$(blue)$ACTIVE_UI$(norm)"
    else
        printf "\033[38;5;208m%s\033[m\n" "$ACTIVE_UI"
    fi
}
