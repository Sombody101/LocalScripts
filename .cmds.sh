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

alias sonar-make='build-wrapper-linux-x86-64 --out-dir build_wrapper_output_directory make'

flag WSL && {
    USER_="/mnt/c/Users/????s"
    alias "$USER_"='cd $USER_'
    alias docs='cd $USER_/Documents/'
    alias down='cd $USER_/Downloads'
}
