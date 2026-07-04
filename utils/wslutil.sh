#!/bin/bash

# shellcheck disable=SC2120
core::mount_drives() {
    : ".loader: core::mount_drives"
    core::hide_trace

    # OS check
    ! flag WSL && {
        core::warn "!WSL: $WSL_DISTRO_NAME: Cannot mount drives (Not WSL)"
        return 1
    }

    ! sudo -n true && {
        core::warn "Sudo not available. Skipping drive mount."
        return 1
    }

    local uid=$(id -u "$USER")
    local gid=$(id -g "$USER")

    for letter in {a..z}; do
        local mount="/mnt/$letter"

        if [[ -d "$mount" ]]; then
            mountpoint -q "$mount" || sudo mount -t drvfs "$letter": "$mount" -o uid="$uid",gid="$gid",metadata &>/dev/null || {
                core::warn -s "${letter^}:\\ not mounted on Windows :: Cannot mount to $mount [[$?]"
                : "Unable to mount win drive $letter:\\ :: NOT_CONNECTED"
                continue
            }

            [[ -d "$mount/.BACKUPS" ]] && export DRIVE="$mount"
        fi

    done
}

init_wsl_tools() {
    ! flag WSL && return
     
    path.add '/mnt/c/rsl/platform-tools'
    path.add "$DOTNET_ROOT:$DOTNET_ROOT/tools:$HOME/.local/bin"
    _tmp_vspath=$(path.towsl 'C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\IDE')
    [[ -d $_tmp_vspath ]] && path.add "$_tmp_vspath"
    alias vsx='devenv.exe'

    unset _tmp_vspath

    WIN_USER="$(echo /mnt/c/Users/${USER}?)"
    DOWNLOADS="$WIN_USER/Downloads"
    DOCUMENTS="$WIN_USER/Documents"

    docs() { cd "$DOCUMENTS"; }
    down() { cd "$DOWNLOADS"; }

}