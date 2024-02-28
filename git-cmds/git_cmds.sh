#!/bin/bash

# alias igm='git status >/dev/null' # IsGitManaged

regload "$GC"

igm() {
    git status "$*" >$NULL
}

git_upload()
{
    : "git-cmds: git_upload"

    local dir
    dir="$*"
    [[ "$dir" == "" ]] && dir="."

        
    [ ! -d "$dir" ] && {
        warn "Failed to find '$dir'"
        return 1
    }

    if ! igm "$dir"; then
        warn "Not a git repository"
        return 1
    fi


    local current
    current=$(pwd)

    cd "$dir"

    git add .
}