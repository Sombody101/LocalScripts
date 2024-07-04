#!/bin/bash

ACTIVE_UIP="$HOME/..ACTIVE_UI"

[ ! -f "$ACTIVE_UIP" ] && {
    warn "No ACTIVE_UI : Creating one (Newest known)"
    echo "custom_1" >"$ACTIVE_UIP"
}

ACTIVE_UI=$(cat "$ACTIVE_UIP")
UIP="$HOME/LocalScripts/utils/cps"

__legacy_set_ui() {
    if [[ "$ACTIVE_UI" == "kali" ]]; then
        # override default virtualenv indicator in prompt
        VIRTUAL_ENV_DISABLE_PROMPT=1
        PROMPT_ALTERNATIVE=twoline
        NEWLINE_BEFORE_PROMPT=yes

        prompt_color='\[\033[;32m\]'
        info_color='\[\033[1;34m\]'
        prompt_symbol=㉿
        if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
            prompt_color='\[\033[;94m\]'
            info_color='\[\033[1;31m\]'
            # Skull emoji for root terminal
            prompt_symbol=💀
        fi

        case "$PROMPT_ALTERNATIVE" in
        twoline)
            PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_color')}('$info_color'\u'$prompt_symbol'\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] '
            ;;
        oneline)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ '
            ;;
        backtrack)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            ;;
        esac
        unset prompt_color
        unset info_color
        unset prompt_symbol
    elif [[ "$ACTIVE_UI" == "ubuntu" ]]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    elif [[ "$ACTIVE_UI" == "custom_1" ]]; then
        PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u\[\e[94m\]@\[\e[94m\]\h\[\e[0;32m\])-[\[\e[38;5;46;1m\]\w\[\e[0;32m\]] [\[\e[32m\]$?\[\e[32m\]]\n\[\e[32m\]╰─\[\e[94;1m\]\$\[\e[0m\] '
        # Emergency version is set in .emergency_backup_loader.sh
    fi
}

KALI() {
    : ".cmds.sh: KALI"
    [[ "$ACTIVE_UI" == "KALI" ]] && {
        echo "Already in KALI"
        return
    }

    echo "KALI" >"$ACTIVE_UIP"
    ref
}

UBUNTU() {
    : ".cmds.sh: UBUNTU"
    [[ "$ACTIVE_UI" == "UBUNTU" ]] && {
        echo "Already in UBUNTU"
        return
    }

    echo "UBUNTU" >"$ACTIVE_UIP"
    ref
}

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
            return
        }

        : $ps1_name -\> $ACTIVE_UIP
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
        [ -f "$HOME/LocalScripts/utils/cps/$1" ] && {
            local new_ui_name="$1"
            shift
            shift_ui "$new_ui_name" "$(cat "$HOME/LocalScripts/utils/cps/$new_ui_name")" "$@"
            return
        }

        warn "Failed to find UI '$1' in \$LS/utils/cps/"
        return 1
        ;;

    esac
}

[[ "$ACTIVE_UI" ]] && {
    ui "$ACTIVE_UI" !-r -s -f
}

# Keep script from returning 1 when nothing bad happened
: