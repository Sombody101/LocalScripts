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

    echo -ne "$CYAN$BACKS$NORM -> $CYAN$___full_backup_path$NORM\r\n"
    shopt -s dotglob

    local type=
    local suffix=
    for item in "$BACKS/"*; do
        [[ "$item" == *"/.git" ]] && continue

        #case $item in
        #    *"/.git") continue ;;
        #esac

        type="./file"
        suffix=
        [ -d "$item" ] && {
            type="-r dir"
            suffix='/'
        }

        echo "[cp $type -> $YELLOW\$LS$NORM]: ${item//$BACKS\//}$suffix"
        sudo cp -r "$item" "$___full_backup_path"
    done

    shopt -u dotglob

    echo "Updating emergency loader file..."
    sudo cp "$EBG/.emergency_backup_loader.sh" "$HOME/LocalScripts"

    #if [ ! -f "$___full_backup_path/backup_version.sh" ]; then
    #    echo -ne "#!/bin/bash\n" | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null
    #fi

    echo "Adding version number..."
    #echo -ne "#!/bin/bash\nemergency_backup_version=\"$(date +'%m.%d.%Y')\"\n" \
    #    | sudo tee -a "$___full_backup_path/backup_version.sh" 2>&1 >/dev/null

    local dt=
    dt="$(date +'%m.%d.%Y')"

    local backv="$___full_backup_path/backup_version.sh"
    local tmpbackv="$HOME/backup_version.sh"

    echo "Signing with: $dt"

    echo -ne "#!/bin/bash\nemergency_backup_version=\"$dt\"\n" >"$tmpbackv"
    sudo mv "$tmpbackv" "$backv"

    echo "New backup created"
}
