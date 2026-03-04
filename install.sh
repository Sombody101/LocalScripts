#!/bin/bash

[[ "$0" == "--help" || "$0" == "-h" ]] && {
    echo 'Installs LocalScripts to start with .bashrc'
    echo '  -r: Restart shell after installing (Replaces current shell process)'
    echo
}

bash_rc="$HOME/.bashrc"
LS=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

function exit_script() {
    # In case someone sourced the file instead of running it with bash
    unset bash_rc

    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit "${1:-1}"
    else
        return "${1:-1}"
    fi
}

echo "Downloading utilities"

# shellcheck disable=SC1091
source "$LS/utils/cum.sh"

utils.install

source "$LS/.extern-utils.sh"

[[ ! -f "$bash_rc" ]] && {
    echo "There is no .bashrc file!"
    echo "Create one and try again."
    exit_script
}

echo "Adding .loader.bashrc to ~/.bashrc..."
echo "Attempting localscripts import..."

loader_path="$LS/.loader.bashrc"

[[ ! -f "$loader_path" ]] && {
    echo "Failed to start localscripts, installation failed."
    exit_script 1
}

import_title="# Import LocalScripts"
if grep -q "$import_title" "$bash_rc"; then
    {
        echo -e "\n\n$import_title"
        echo "if [[ \$NOLS ]]; then : Skipping LocalScripts;"
        echo "elif [[ -d '$LS' && -f '$LS/.loader.bashrc' ]]; then"
        echo "  source '$LS/.loader.bashrc'"
        echo "else"
        echo "  echo 'Unable to find .loader.bashrc!'"
        echo "  echo 'Check if it was removed, or reinstall it from GitHub'"
        echo "fi"
    } >>"$bash_rc"
fi

[[ "$0" == "-r" ]] && {
    # Restart shell
    exec "$SHELL"
}

echo "LocalScripts installed."

exit_script 0
