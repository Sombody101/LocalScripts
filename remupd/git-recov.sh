#!/bin/bash

regload "git-recov.sh (gitupdate)"

gitupdate() {
    [ -v sdev ] && {
        warn "Cannot clone LocalScripts from remote while on $(hostname)"

        if [[ "$*" =~ -f ]]; then
            warn "Found '-f': Bypassing developer machine restriction (Not suggested on Ubutnu machine)"
        else
            return 1
        fi
    }

    [[ "$*" =~ clean ]] && {
        [[ "$sdev" ]] && {
            warn "Cannot remove LocalScripts while on the developer machine (not forceable)"
            return 255
        }

        echo "Clearing current LocalScripts install"
        sudo rm -r "$HOME/LocalScripts"
    }

    get_remote_update() {

        # Safe-CD
        scd() {
            pushd "$*" || {
                echo "Failed to cd into '$*'"
                exit
            }
        }

        local folder

        folder="$HOME/tmp-GIT"

        # Create temp directory
        [[ -d "$folder" ]] && sudo rm -r "$folder" # Cleanup if it still exists
        mkdir "$folder"
        scd "$folder"

        local repo=
        local using_group=TRUE

        case "$1" in
        "local"*) {
            repo="LocalScripts"
            using_group=FALSE
        } ;;
        "ext" | *) {
            repo="bash-ext"
        } ;;

        esac
        echo "Downloading from $repo"
        echo

        # Get extension repo
        command git clone "https://github.com/Sombody101/$repo.git" || {
            warn "Failed to update LocalScripts"
            return 1
        }

        # Copy files if the clone was a success
        if [[ "$using_group" == "TRUE" ]] && [[ -d "bash-ext" ]]; then
            scd "$folder"
            git submodule update --init
            sudo cp -r "$folder/LocalScripts/" "$HOME"
        else
            sudo cp -r "$folder/LocalScripts/" "$HOME"
        fi

        [ -d "$folder" ] && sudo rm -r "$folder"
        dirs -c
    }

    # Use sub-shell
    (get_remote_update "$*")
}
