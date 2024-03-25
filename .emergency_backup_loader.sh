#!/bin/bash

[[ ! "$___full_backup_path" ]] && {
    # Option for it to be set externally
    ___full_backup_path="$HOME/LocalScripts/.emergency_bashext_backup"
}

white 2>"$NULL" # Set text color

sprint() {
    # Not a server and not unknown (Give backup info for devices that use this as a backup and not the lib itself)
    if [ ! -v server ] && [ ! -v unknown ]; then
        echo "$*"
    fi
}

initialize_sd_backup() {
    DRIVE="$HOME/LocalScripts" # .BACKUP.sh uses $DRIVE to locate itself, so we need to redefine it from the SD to LocalScripts

    using "$___full_backup_path/backup_version.sh" -f
    if [[ "$emergency_backup_version" ]]; then
        sprint "Using $(yellow)v$emergency_backup_version$(white)"

        # Set new PS1
        #PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u@\h\[\e[0;32m\])-[\[\e[92;1m\]\w\[\e[0;32m\]] [$?] [\[\e[93m\]v${emergency_backup_version:-}\[\e[32m\]]\n╰─\[\e[94;1m\]\$\[\e[0m\] '
        [[ "$ACTIVE_UI" == "custom_1"* ]] && {
            ui custom_1_version -!r -s -f -nosave
        }
    else
        if [[ "$server" ]]; then
            warn "No extension functions found"
        else
            warn "No SD backup version | Unknown functions"
        fi

        #PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u@\h\[\e[0;32m\])-[\[\e[92;1m\]\w\[\e[0;32m\]] [$?] [$(__get_emergency_var)]\n╰─\[\e[94;1m\]\$\[\e[0m\] '
        [[ "$ACTIVE_UI" == "custom_1"* ]] && {
            ui custom_1_noversion -!r -s -f -nosave
        }
    fi

    # Set variable to signify backup environment
    export backup_env="TRUE"

    export DRIVE="$___full_backup_path"

    # This is the entry point; Everything will be handled from there
    using "$___full_backup_path/bashext.sh" -f || {
        warn "Failed to find bashext entry point"
        return 1
    }

    # Clear cached drive to prevent errors when going back to "full" bash-ext
    # : >"$HOME/.active_drive"
}

sprint "Checking emergency backup status..."
if [ -d "$___full_backup_path" ]; then
    sprint "Found emergency backup"
    initialize_sd_backup
else
    sprint "No backup directory [$___full_backup_path]" # Just skip the loading function (there's nothing to load anyway)
fi

unset ___full_backup_path \
    initialize_sd_backup \
    sprint
