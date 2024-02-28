#!/bin/bash

fromRGB(){
    if [[ $1 != "" ]]; then
        local COLOR="\033[38;2;$1;$2;$3m"
        printf "%s This is what your color looks like" "$COLOR"
    fi
}

__T=.05
Sprint() { # Sprint: Slow Print (Makes text seem cooler)
    Text="$*"
    for ((i = 0; i < ${#Text}; i++)); do
        echo -ne "${Text:$i:1}"
        sleep $__T
    done
    [[ $LINE == "TRUE" ]] && echo
}

CMDS() {
    echo
    white
    echo "   $(blue)Available Commands:"
    echo "$(yellow)${__PREF}__SHOW__EASTEREGGS$(blue): Prints eastereggs $(white)[Current Status: $(_CHECK "$__SHOW_EASTEREGGS")$__SHOW_EASTEREGGS$(white)]"
    echo "$(yellow)${__PREF}LIST$(blue): Prints debug variables."
    echo "$(yellow)${__PREF}dec$(blue): Allows user to create/change environment variables. $(white)(dec $(green)=> $(white)Declare)"
    echo "     ├─> $(cyan)Use '$(green)not$(cyan)' to inverse boolean variables"
    echo "     $(white)├─> $(cyan)Add '$(green)__$(cyan)' to the name of the variable for it to shown on 'LIST'"
    echo "     $(white)└─> $(magenta)Booleans are represented as '$(green)TRUE$(magenta)'/'$(red)FALSE$(magenta)'"
    echo "     $(red) WARNING: THIS COMMAND USES EVAL, SO USE WITH CAUTION"
    echo "$(yellow)${__PREF}_FETCH_DEVICE$(blue): Fetches hardware data and stores it to a .json file$(white)"
    echo "     └─> $(cyan)$__CMDS/.Settings.json"
    echo "$(yellow)${__PREF}"
}

SHOW_EASTEREGGS() {
    echo ""
    tput setaf 3
    echo " Eastereggs:"
    echo "Type 'I want to see you' in first interaction with any of the 'people'"
}
