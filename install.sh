#!/bin/bash

[[ "$0" == "--help" || "$0" == "-h" ]] && {
    echo 'Installs LocalScripts to start with .bashrc'
    echo '  -r: Restart shell after installing (Replaces current shell process)'
    echo
}

bash_rc="$HOME/.bashrc"

function exit_script() {
    # In case someone sourced the file instead of running it with bash
    unset bash_rc write_rc

    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit "${1:-1}"
    else
        return "${1:-1}"
    fi
}

[[ ! -f "$bash_rc" ]] && {
    echo "There is no .bashrc file!"
    echo "Create one and try again."
    exit_script
}

function write_rc() {
    printf '%s\n' "$*" >>"$bash_rc"
}

echo "Adding .loader.bashrc to ~/.bashrc..."

# Padding/importer
write_rc
write_rc
write_rc '# Import LocalScripts'
write_rc 'if [[ -d "$HOME/LocalScripts/" ]]; then'
write_rc '  source "$HOME/LocalScripts/.loader.bashrc"'
write_rc 'else'
write_rc '  echo "Unable to find .loader.bashrc!"'
write_rc '  echo "Check if it was removed, or reinstall it from GitHub"'
write_rc 'fi'

[[ "$0" == "-r" ]] && {
    # Restart shell
    exec "$SHELL"
}

exit_script 0
