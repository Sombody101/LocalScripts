#!/bin/bash

readonly ACTIVE_UIP="$HOME/.active_ui"

[ ! -f "$ACTIVE_UIP" ] && {
    core::warn "No ACTIVE_UI : Creating one (Newest known)"
    echo "custom_1" >"$ACTIVE_UIP"
}

ACTIVE_UI=$(cat "$ACTIVE_UIP")
UIP="$LS/utils/cps"

ui() {
    : ".cmds.sh: ui"

    shift_ui() {
        local ps1_name="$1" \
            new_ps1="$2" \
            reset="$3" \
            silent="$4" \
            force="$5" \
            nosave=$"$6"

        [[ "$ACTIVE_UI" == "$ps1_name" ]] && [[ "$force" != "-f" ]] && {
            [[ "$silent" != "-s" ]] && echo "Already in $ps1_name"
            return 0
        }

        : "$ps1_name -> $ACTIVE_UIP"
        [[ "$nosave" != "-nosave" ]] && echo "$ps1_name" >"$ACTIVE_UIP"

        new_ps1="${new_ps1:-Failed to set PS1>}"
        PS1="$new_ps1 "
        ACTIVE_UI="$ps1_name"

        [[ "$reset" == "-r" ]] && ref
    }

    case "$*" in
    "")
        local stored_ui output

        stored_ui="$(cat "$ACTIVE_UIP")"
        output="$ACTIVE_UI"

        [[ "$stored_ui" != "$ACTIVE_UI" ]] && {
            output="$stored_ui ($ACTIVE_UI)"
        }

        printf "\033[38;5;208m%s\033[m\n" "$output"
        ;;

    "ubuntu")
        shift_ui "ubuntu" "$(cat "$UIP/ubuntu")" "$@"
        ;;

    "kali")
        shift_ui "kali" "$(cat "$UIP/kali")" "$@"
        ;;

    "new")
        shift_ui "custom_1" "$(cat "$UIP/custom_1")" "$@"
        ;;

    *)
        [[ -f "$LS/utils/cps/$1" ]] && {
            local new_ui_name="$1"
            shift
            shift_ui "$new_ui_name" "$(cat "$LS/utils/cps/$new_ui_name")" "$@"
            return 0
        }

        core::warn "Failed to find UI '$1' in \$LS/utils/cps/"
        return 1
        ;;

    esac
}

__ui_autocomplete() {
    local cur prev

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    if [[ "$prev" == "ui" ]]; then
        local file_dir="$LS/utils/cps"
        read -ar COMPREPLY <<<"$(compgen -f -d -- "$file_dir/$cur" 2>/dev/null | sed "s|^$file_dir/||")"
    else
        COMPREPLY=()
    fi
}

complete -F __ui_autocomplete ui

[[ "$ACTIVE_UI" ]] && {
    ui "$ACTIVE_UI" !-r -s -f
}

# Keep script from returning 1
:
