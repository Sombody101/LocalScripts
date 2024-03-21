#!/bin/bash

# Source the independant file for each computer if it's there
using "$HOME/.ind.sh" -f

blue
echo -ne 'Imported     '
[[ "$ACTIVE_UI" != "ubuntu" ]] && echo
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