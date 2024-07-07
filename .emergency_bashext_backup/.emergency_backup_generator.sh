#!/bin/bash

___full_backup_path="$LS/.emergency_bashext_backup"

# Copies $BACKS to $HOME/LocalScripts
dump_all_sh_from_sd() {

    local type suffix dt backv

    [[ "$emergency_backup_version" ]] && {
        warn "Cannot create a bash-ext backup while working in the emergency environment"
        echo "Version: $emergency_backup_version"
        return 155
    }

    [[ -d "$___full_backup_path" ]] && {
        warn "Removing current backup from '$___full_backup_path'"
        sudo rm -r "$___full_backup_path"
    }

    echo -ne "$CYAN$BACKS$NORM -> $CYAN$___full_backup_path$NORM\n"
    shopt -s dotglob

    for item in "$BACKS/"*; do
        # Don't backup git or compiled apps
        if [[ "$item" == *"/.git" ]] || [[ "$item" == *"/.apps" ]]; then
            continue
        fi

        type="./file"
        suffix=
        [[ -d "$item" ]] && {
            type="-r dir"
            suffix='/'
        }

        echo "[cp $type -> $YELLOW\$LS$NORM]: ${item//$BACKS\//}$suffix"
        cp -r "$item" "$___full_backup_path"
    done

    shopt -u dotglob

    echo "Updating emergency loader file..."
    cp "$EBG/.emergency_backup_loader.sh" "$HOME/LocalScripts"

    echo "Adding version number..."

    dt="$(date +'%m.%d.%Y')"

    backv="$___full_backup_path/backup_version.sh"

    echo "Signing with: $dt"
    echo -e "#!/bin/bash\nemergency_backup_version=\"$dt\"\n" >"$backv"

    echo "Making readonly"
    chmod 500 -R "$___full_backup_path"
    chmod 500 "$LS/.emergency_backup_loader.sh"

    echo "New backup created"
}
