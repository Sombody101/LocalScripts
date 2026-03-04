#!/bin/bash

# Cheap Utility Manager
# This file can't use LS/bashext utilities because it needs to be bare-minimum for use in 
# the LS install script, other than the LS path variable (which can and should be set prior to use)

utils.update() {
    # It's an illusion
    utils.install
}

utils.install() {
    source "$LS/.extern-utils.sh"
    for link_name in "${!utils[@]}"; do
        repo="${utils[$link_name]}"
        util_name="${repo##*/}"
        __utils.download_util "$repo" "$util_name" "$link_name"
    done
    unset utils
}

__utils.download_util() {
    local repo="$1" util="$2" slink="$3" arch release_data release_version url

    local readonly __local_bins="$HOME/.local/bin"
    local readonly __local_opts="$HOME/.local/opt"
    mkdir -p "$__local_opts"
    mkdir -p "$__local_bins"

    echo "Downloading $util"

    case $(uname -m) in
    "x86_64") arch="x64" ;;
    "aarch64") arch="a64" ;;
    "armv7l") arch="a32" ;;
    *) {
        echo "Unknown architecture $(uname -m)"
        return 1
    } ;;
    esac

    release_data=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
    release_version=$(echo "$release_data" | jq -r '.tag_name')
    local version_dir="$__local_opts/$util/$release_version"
    local download_bin="$version_dir/${util}-lin-${arch}"

    [[ -d "$version_dir" ]] && {
        echo "$util is already up to date ($release_version)"
        return
    }

    url=$(echo "$release_data" | jq -r ".assets[] | select(.name | contains(\"lin-${arch}\")) | .browser_download_url")

    echo "Installing $util $release_version"
    mkdir -p "$version_dir"
    ! wget -q --show-progress "$url" -O "$download_bin" && {
        echo "Failed to download $util"
        return 1
    }

    chmod +x "$download_bin"

    echo "Linking $util to $slink"
    ln -sf "$download_bin" "$__local_bins/$slink"
}
