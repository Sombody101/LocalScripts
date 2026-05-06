#!/bin/bash

token() {
    flag WSL || {
        core::error "Not WSL"
        return
    }

    [[ "$backup_env" ]] && {
        core::error "Tokens are not available in a backup environment."
        return
    }

    [[ ! "$DRIVE" ]] && {
        core::error "Drive path is not set."
        return
    }

    [[ ! "$1" ]] && {
        core::error "No token name supplied."
        return
    }

    ! cat "$DRIVE"/z-?????/"$1".to? 2>/dev/null && core::error "No token file '$1' found."
}
