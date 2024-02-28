#!/bin/bash

___full_backup_path="$HOME/LocalScripts/.emergency_bashext_backup"

# Copies $BACKS to $HOME/LocalScripts
dump_all_sh_from_sd() {

    [[ "$emergency_backup_version" ]] && {
        warn "Cannot create a bash-ext backup while working in the emergency environment"
        echo "Version: $emergency_backup_version"
        return 155
    }

    [ -d "$___full_backup_path" ] && {
        warn "Removing current backup from '$___full_backup_path'"
        sudo rm -r "$___full_backup_path"
    }

    echo "Making copy of $BACKS in $___full_backup_path"
    shopt -s dotglob
    for item in "$BACKS/"*; do
        case $item in
            *"/.git") continue ;;
        esac

        echo "Moving: ${item//$BACKS\//}"
        sudo cp -r "$item" "$___full_backup_path"
    done
    shopt -u dotglob

    echo "Updating emergency loader file..."
    sudo cp "$EBG/.emergency_backup_generator.sh" "$HOME/LocalScripts"

    #if [ ! -f "$___full_backup_path/backup_version.sh" ]; then
    #    echo -ne "#!/bin/bash\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null
    #fi

    echo "Adding version number..."
    echo -ne "#!/bin/bash\nemergency_backup_version=\"$(date +'%m.%d.%Y')\"\n" \
        | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null

    echo "New backup created"
}
