#!/bin/bash

# Allows for the backup path to be set externally
[[ ! "$___full_backup_path" ]] && {
    ___full_backup_path="$LS/.emergency_bashext_backup"
}

white 2>"$NULL" # Set text color

sprint() {
    # Not a server and not unknown (Only give information when used as a backup, not a library)
    ! flag SERVER UNKNOWN && {
        echo "$*"
    }
}

initialize_sd_backup() {
    DRIVE="$LS" # .BACKUP.sh uses $DRIVE to locate itself, so we need to redefine it from the SD to LocalScripts

    using "$___full_backup_path/backup_version.sh" -f
    if [[ "$emergency_backup_version" ]]; then
        # Known BashExt version

        sprint "Using $(yellow)v$emergency_backup_version$(white)"

        # Set new PS1
        #PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u@\h\[\e[0;32m\])-[\[\e[92;1m\]\w\[\e[0;32m\]] [$?] [\[\e[93m\]v${emergency_backup_version:-}\[\e[32m\]]\n╰─\[\e[94;1m\]\$\[\e[0m\] '
        [[ "$ACTIVE_UI" =~ ^"custom_1" ]] && {
            ui custom_1_version -!r -s -f -nosave
        }
    else
        # Unknown BashExt version

        if [[ "$server" ]]; then
            warn "No extension functions found"
        else
            warn "No BashExt backup version | Unknown functions"
        fi

        #PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u@\h\[\e[0;32m\])-[\[\e[92;1m\]\w\[\e[0;32m\]] [$?] [$(__get_emergency_var)]\n╰─\[\e[94;1m\]\$\[\e[0m\] '
        [[ "$ACTIVE_UI" =~ ^"custom_1" ]] && {
            ui custom_1_noversion -!r -s -f -nosave
        }
    fi

    # Set variable to signify backup environment
    backup_env="TRUE"
    DRIVE="$___full_backup_path"
    export backup_env DRIVE

    # This is the entry point; Everything will be handled from there
    using "$___full_backup_path/bashext.sh" -f || {
        warn "Failed to find bashext entry point"
        return 1
    }

    # Clear cached drive to prevent errors when going back to "full" bash-ext
    # : >"$HOME/.active_drive"
}

sprint "Checking emergency backup status..."
if [[ -d "$___full_backup_path" ]]; then
    sprint "Found emergency backup"
    initialize_sd_backup
else
    sprint "No backup directory [$___full_backup_path]" # Just skip the loading function (there's nothing to load anyway)
fi

unset ___full_backup_path \
    initialize_sd_backup \
    sprint
