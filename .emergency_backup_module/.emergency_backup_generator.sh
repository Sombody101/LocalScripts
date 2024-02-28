#!/bin/bash

___full_backup_path="$HOME/LocalScripts/.emergency_bashext_backup"

# Copies $BACKS to $HOME/LocalScripts
dump_all_sh_from_sd() {
    [ -d "$___full_backup_path" ] && {
        warn "Removing current backup from '$___full_backup_path'"
        sudo rm -r "$___full_backup_path"
    }

    echo "Making copy of $BACKS in $___full_backup_path"
    sudo cp -r "$BACKS" "$___full_backup_path"

    echo "Updating emergency loader file..."
    sudo cp "$BACKS/.emergency_backup_module/.emergency_backup_loader.sh" "$HOME/LocalScripts/"

    #if [ ! -f "$___full_backup_path/backup_version.sh" ]; then
    #    echo -ne "#!/bin/bash\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null
    #fi

    echo "Adding version number..."
    echo -ne "#!/bin/bash\nemergency_backup_version=\"$(date +'%m.%d.%Y')\"\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null

    echo "New backup created"
}
