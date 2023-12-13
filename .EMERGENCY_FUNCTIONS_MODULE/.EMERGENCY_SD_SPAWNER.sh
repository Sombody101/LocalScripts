#!/bin/bash

___full_backup_path="$HOME/LocalScripts/.EMERGENCY_BACKUPS"

white 2>"$NULL" # Set text color

write() {
    if [[ $server != TRUE ]]; then
        echo "$*"
    fi
}

initialize_sd_backup() {
    DRIVE="$HOME/LocalScripts" # .BACKUP.sh uses $DRIVE to locate itself, so we need to redefine it from the SD to LocalScripts

    using "$___full_backup_path"/backup_version.sh
    if [[ "$EMERGENCY_SD_VERSION" != "" ]]; then
        write "Using $(yellow)v$EMERGENCY_SD_VERSION$(white)"
    else
        if [[ $server == TRUE ]]; then
            warn "No extension functions found"
        else
            warn "No SD backup version | Unknown functions"
        fi
    fi

    export DRIVE="$___full_backup_path"
    using "$___full_backup_path/.BACKUP.sh" # This is the entry point | Everything will be handled from there
}

[[ $(whoami) == "bench" ]] && server="TRUE"

write "Checking emergency backup status..."
if [ -d "$___full_backup_path" ]; then
    write "Found emergency backup"
    initialize_sd_backup
else
    warn "No backup directory [$___full_backup_path]" # Just skip the loading function (there's nothing to load anyway)
fi

unset ___full_backup_path initialize_sd_backup write
