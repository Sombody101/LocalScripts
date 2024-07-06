#!/bin/bash

# Source the independant file for each computer if it's there
using "$HOME/.ind.sh" -f

blue
echo -ne 'Imported     '
[[ "$ACTIVE_UI" != "ubuntu" ]] && echo
LINE=TRUE
norm

# Register script file
regload "$HOME/LocalScripts/.cmds.sh"

flag WSL && {
    USER_="/mnt/c/Users/????s"
    alias evs='cd $USER_'
    alias docs='cd $USER_/OneDrive/Documents/'
    alias down='cd $USER_/Downloads'
}