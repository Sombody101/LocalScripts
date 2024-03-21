#!/bin/bash

[ ! -f "$HOME/..ACTIVE_UI" ] && {
    warn "No ACTIVE_UI : Creating one (UBUNTU)"
    echo "UBUNTU" >"$HOME/..ACTIVE_UI"
}

ACTIVE_UIP="$HOME/..ACTIVE_UI"
ACTIVE_UI=$(cat "$ACTIVE_UIP")

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
        local wanted_ui="$*"
        [[ "$ACTIVE_UI" == "$wanted_ui" ]] && {
            echo "Already in $wanted_ui"
            return
        }

        echo "$wanted_ui" >"$ACTIVE_UIP"
        ref
    }

    case "$*" in
    "")
        printf "\033[38;5;208m%s\033[m\n" "$ACTIVE_UI"
        ;;

    "ubuntu")
        shift_ui "ubuntu"
        ;;

    "kali")
        shift_ui "kali"
        ;;

    "new")
        shift_ui "custom_1"
        ;;
    esac
}
