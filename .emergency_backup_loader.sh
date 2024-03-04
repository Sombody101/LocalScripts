#!/bin/bash

___full_backup_path="$HOME/LocalScripts/.emergency_bashext_backup"

white 2>"$NULL" # Set text color

PRINT="[ ! -v server ] && [ ! -v unknown ] && echo"

initialize_sd_backup() {
    DRIVE="$HOME/LocalScripts" # .BACKUP.sh uses $DRIVE to locate itself, so we need to redefine it from the SD to LocalScripts

    using "$___full_backup_path/backup_version.sh"
    if [[ "$emergency_sd_version" ]]; then
        $PRINT "Using $(yellow)v$emergency_sd_version$(white)"
    else
        if [[ "$server" == "TRUE" ]]; then
            warn "No extension functions found"
        else
            warn "No SD backup version | Unknown functions"
        fi
    fi

    export DRIVE="$___full_backup_path"
    using "$___full_backup_path/.BACKUP.sh" # This is the entry point | Everything will be handled from there
}

$PRINT "Checking emergency backup status..."
if [ -d "$___full_backup_path" ]; then
    $PRINT "Found emergency backup"
    initialize_sd_backup
else
    $PRINT "No backup directory [$___full_backup_path]" # Just skip the loading function (there's nothing to load anyway)
fi

unset ___full_backup_path initialize_sd_backup PRINT
