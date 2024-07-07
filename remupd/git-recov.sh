#!/bin/bash

gitupdate() {
    flag any HOME MOBILE && {
        core::warn "Cannot clone LocalScripts from remote while on $(hostname)"

        if [[ "$*" =~ "-f" ]]; then
            core::warn "Found '-f': Bypassing developer machine restriction (Not suggested on Ubutnu machine)"
        else
            return 1
        fi
    }

    [[ "$*" =~ "clean" ]] && {
        flag any HOME MOBILE && {
            core::warn "Cannot remove LocalScripts while on the developer machine (not forceable)"
            return 255
        }

        echo "Clearing current LocalScripts install"
        rm -r "$HOME/LocalScripts"
    }

    get_remote_update() {
        local tmp_folder repo using_group

        # Safe-CD
        scd() {
            pushd "$*" || {
                core::warn "Failed to cd into '$*'"
                exit
            }
        }

        tmp_folder="$HOME/tmp-GIT"

        # Create temp directory
        [[ -d "$tmp_folder" ]] && rm -r "$tmp_folder" # Cleanup if it still exists
        mkdir "$tmp_folder"
        scd "$tmp_folder"

        using_group=TRUE

        case "$1" in
        "local"*) {
            repo="LocalScripts"
            using_group=FALSE
        } ;;

        "ext" | *) {
            repo="bash-ext"
        } ;;
        esac

        echo -e "Downloading from $repo\n"

        # Get extension repo
        command git clone "https://github.com/Sombody101/$repo.git" || {
            core::warn "Failed to update LocalScripts"
            return 1
        }

        # Copy files if the clone was a success
        if [[ "$using_group" == "TRUE" ]] && [[ -d "bash-ext" ]]; then
            scd "$tmp_folder"
            git submodule update --init
            cp -r "$tmp_folder/LocalScripts/" "$HOME"
        else
            cp -r "$tmp_folder/LocalScripts/" "$HOME"
        fi

        [ -d "$tmp_folder" ] && rm -rf "$tmp_folder"
        dirs -c
    }

    # Use sub-shell
    (get_remote_update "$*")
}

regload "git-recov.sh (gitupdate)"
