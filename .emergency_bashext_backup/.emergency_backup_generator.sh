#!/bin/bash

___full_backup_path="$LS/.emergency_bashext_backup"

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
        if [[ "$item" == *"/.git" ]] || [[ "$item" == *"/.apps" ]]; then
            continue
        fi

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
        cp -r "$item" "$___full_backup_path"
    done

    shopt -u dotglob

    echo "Updating emergency loader file..."
    cp "$EBG/.emergency_backup_loader.sh" "$HOME/LocalScripts"

    echo "Adding version number..."

    local dt=
    dt="$(date +'%m.%d.%Y')"

    local backv="$___full_backup_path/backup_version.sh"

    echo "Signing with: $dt"
    echo -e "#!/bin/bash\nemergency_backup_version=\"$dt\"\n" >"$backv"

    echo "Making readonly"
    chmod 500 -R "$___full_backup_path"
    chmod 500 "$LS/.emergency_backup_loader.sh"

    echo "New backup created"
}
