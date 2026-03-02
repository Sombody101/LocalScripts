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

download_util() {
    local repo="$1" util="$2" slink="$3" arch release_data release_version url

    echo "Downloading $util"

    case $(uname -m) in
    "x86_64") arch="x64" ;;
    "aarch64") arch="a64" ;;
    "armv7l") arch="a32" ;;
    *) {
        echo "Unknown architecture $(uname -m)"
        exit_script 1
    } ;;
    esac

    release_data=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
    release_version=$(echo "$release_data" | jq -r '.tag_name')
    local version_dir="$local_opts/$util/$release_version"
    local download_bin="$version_dir/${util}-lin-${arch}"

    [[ -d "$version_dir" ]] && {
        echo "$util is already up to date ($release_version)"
        return
    }

    url=$(echo "$release_data" | jq -r ".assets[] | select(.name | contains(\"lin-${arch}\")) | .browser_download_url")

    echo "Installing $util $release_version"
    mkdir -p "$version_dir"
    ! wget -q "$url" -O "$download_bin" && {
        echo "Failed to download $util"
        return 1
    }

    chmod +x "$download_bin"

    echo "Linking $util to $slink"
    ln -sf "$download_bin" "$local_bins/$slink"
}

readonly local_bins="$HOME/.local/bin"
readonly local_opts="$HOME/.local/opt"
mkdir -p "$local_opts"
mkdir -p "$local_bins"

source "$LS/.extern-utils.sh"

for link_name in "${!utils[@]}"; do
    repo="${utils[$link_name]}"
    util_name="${repo##*/}"
    download_util "$repo" "$util_name" "$link_name"
done

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
