#!/bin/bash

# Source the independent file for each computer if it's there
using "$HOME/.ind.sh" -f

blue
echo -ne 'Imported     '
# Add an extra line if PS1, because ui-ubuntu doesn't use two lines.
#[[ "$ACTIVE_UI" != "ubuntu" ]] && echo
[[ "$PS1" == *'\n'* ]] && echo
LINE=TRUE
norm

# Register script file
regload "$HOME/LocalScripts/.cmds.sh"

flag WSL && {
    WIN_USER="$(echo /mnt/c/Users/${USER}?)"
    DOWNLOADS="$WIN_USER/Downloads"
    DOCUMENTS="$WIN_USER/Documents"

    docs() { cd $DOCUMENTS; }
    down() { cd $DOWNLOADS; }
}
