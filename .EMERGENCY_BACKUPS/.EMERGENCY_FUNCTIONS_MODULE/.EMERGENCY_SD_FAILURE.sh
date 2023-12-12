#!/bin/bash

# This file creates a "backup" of imporant functions that are only located on this SD card. They will be placed in a file in LocalScripts
# that way they can be used even when the SD card is lost or damaged.

# ONLY FUNCTIONS, NO ALIASES
___commands_to_backup=(
    command_not_found_handle # Error handler (Also what gives math stuff, so pretty important)
    vs                       # Probably one of the most used commands that will definitley need to be backed up
    showPath
    distraction
    pathify
    warn
)

___backup_path="$HOME/LocalScripts/.EMERGENCY_SD_FAILURE.sh"

# Dumps functions to file to be sourced
create_sd_command_backup() {
    # Create the emergency file if it hasnt been created already
    [ ! -f "$___backup_path" ] && {
        echo -ne "#!/bin/bash\n" >>"$___backup_path"
    } || {
        echo -ne "\n# COMMAND OVERRIDES #\n" >>"$___backup_path"
    }

    for cmd in "${___commands_to_backup[@]}"; do
        local fCmd=
        fCmd="$(type "$cmd" | tail -n +2)"
        [[ "$fCmd" == "" ]] && {
            warn "Failed to find full command for '${cmd}' | Check if it has been loaded"
            continue
        }

        echo "Writing '$cmd' to '$___backup_path'"
        while IFS= read -r line; do
            echo "$line"
        done <<<"${fCmd}" >>"$___backup_path"
        echo -ne "\n" >>"$___backup_path"
    done
    echo -ne "\nEMERGENCY_CMD_VERSION=\"$(date +'%d.%m.%Y')\"\n" >>"$___backup_path"
}

# This is a REAL emergency backup
# This will backup ALL important .sh SD files

___full_backup_path="$HOME/LocalScripts/.EMERGENCY_BACKUPS"

# Copies $BACKS to $HOME/LocalScripts
dump_all_sh_from_sd() {
    [ -d "$___full_backup_path" ] && {
        warn "Removing current backup from '$___full_backup_path'"
        sudo rm -r "$___full_backup_path"
    }

    echo "Making copy of $BACKS in $___full_backup_path"
    sudo cp -r "$BACKS" "$___full_backup_path"

    echo "Updating emergency spawn file..."
    sudo cp "$BACKS"/.EMERGENCY_FUNCTIONS_MODULE/.EMERGENCY_SD_SPAWNER.sh "$HOME"/LocalScripts

    #if [ ! -f "$___full_backup_path/backup_version.sh" ]; then
    #    echo -ne "#!/bin/bash\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null
    #fi

    echo "Adding version number..."
    echo -ne "#!/bin/bash\nEMERGENCY_SD_VERSION=\"$(date +'%m.%d.%Y')\"\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null

    echo "New backup created"
}
