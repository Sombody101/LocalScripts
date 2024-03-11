#!/bin/bash

___full_backup_path="$HOME/LocalScripts/.emergency_bashext_backup"

white 2>"$NULL" # Set text color

sprint() {
    # Not a server and not unknown (Give backup info for devices that use this as a backup and not the lib itself)
    if [ ! -v server ] && [ ! -v unknown ]; then
        echo "$*"
    fi
}

initialize_sd_backup() {
    DRIVE="$HOME/LocalScripts" # .BACKUP.sh uses $DRIVE to locate itself, so we need to redefine it from the SD to LocalScripts

    using "$___full_backup_path/backup_version.sh"
    if [[ "$emergency_backup_version" ]]; then
        sprint "Using $(yellow)v$emergency_backup_version$(white)"
    elif [[ "$server" ]]; then
        warn "No extension functions found"
    else
        warn "No SD backup version | Unknown functions"
    fi

    export DRIVE="$___full_backup_path"
    using "$___full_backup_path/bashext.sh" # This is the entry point | Everything will be handled from there
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
