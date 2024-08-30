#!/bin/bash

___full_backup_path="$LS/.emergency_bashext_backup"

# Copies $BACKS to $HOME/LocalScripts
dump_all_sh_from_sd() {


    [[ "$emergency_backup_version" ]] && {
        core::warn "Cannot create a bash-ext backup while working in the emergency environment"
        echo "Version: $emergency_backup_version"
        return 155
    }

    [[ -d "$___full_backup_path" ]] && {
        core::warn "Removing current backup from '$___full_backup_path'"
        sudo rm -r "$___full_backup_path"
    }

    mkdir -p "$___full_backup_path"

    echo -ne "$CYAN$BACKS$NORM -> $CYAN$___full_backup_path$NORM\n"
    shopt -s dotglob
    
    local type suffix dt backv

    for item in $(find "$BACKS" -not -path "*.git/*"); do

        [[ "$item" == "$BACKS" ]] && continue

        # Don't backup git or compiled apps
        case "${item}" in
        ".." | "." | *"/.git" | *"/.apps"*)
            continue
            ;;
        esac

        type="./file"
        suffix=
        [[ -d "$item" ]] && {
            type="-r dir"
            suffix='/'
        }

        local out_path="${item//$BACKS\//}"
        echo "[cp $type -> $YELLOW\$LS$NORM]: ${out_path}$suffix"
        cp -r "$item" "$___full_backup_path/$out_path"
    done

    shopt -u dotglob

    echo "Updating emergency loader file..."
    cp -f "$EBG/.emergency_backup_loader.sh" "$LS"

    echo "Adding version number..."

    dt="$(date +'%m.%d.%Y')"

    backv="$___full_backup_path/backup_version.sh"

    echo "Signing with: $dt"

    echo -e "#!/bin/bash\nemergency_backup_version=\"$dt\"\n" >"$backv"

    # Restore readonly
    chmod 500 -R "$___full_backup_path"
    chmod 500 "$LS/.emergency_backup_loader.sh"

    echo "New backup created"
}
