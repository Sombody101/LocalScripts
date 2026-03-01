#!/bin/bash

[[ "$0" == "--help" || "$0" == "-h" ]] && {
    echo 'Installs LocalScripts to start with .bashrc'
    echo '  -r: Restart shell after installing (Replaces current shell process)'
    echo
}

bash_rc="$HOME/.bashrc"

function exit_script() {
    # In case someone sourced the file instead of running it with bash
    unset bash_rc

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

echo "Adding .loader.bashrc to ~/.bashrc..."
echo "Attempting localscripts import..."

loader_path="$(dirname "${BASH_SOURCE[0]}")/.loader.bashrc"

[[ ! -f "$loader_path" ]] && {
    echo "Failed to start localscripts, installation failed."
    exit_script 1
}

{
    echo -e '\n\n# Import LocalScripts'
    echo "if [[ \$NOLS ]]; then : Skipping LocalScripts;"
    echo "elif [[ -d '$LS' && -f '$LS/.loader.bashrc' ]]; then"
    echo "  source '$LS/.loader.bashrc'"
    echo "else"
    echo "  echo 'Unable to find .loader.bashrc!'"
    echo "  echo 'Check if it was removed, or reinstall it from GitHub'"
    echo "fi"
} >>"$bash_rc"

[[ "$0" == "-r" ]] && {
    # Restart shell
    exec "$SHELL"
}

echo "LocalScripts installed."

exit_script 0
