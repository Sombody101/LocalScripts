#!/bin/bash

#
# Quick shell configurations
#

[[ "$DEBUG" ]] && set -x

[[ ! "$__PROFILER_RUN" ]] && { 
    # So the prompt never has colors bleeding from a previous command
    export PS1="\[\033[0m\]$PS1"
    export PS4='#| \[$YELLOW\]$(basename ${BASH_SOURCE%.sh} 2>/dev/null):\[$RED\]${LINENO}:\[$(echo -ne "\e[38;2;255;165;0m")\]${FUNCNAME[0]// /:+ \[$NORM\]:}\[$CYAN\][${SHLVL},${BASH_SUBSHELL},$?]\[$NORM\]: '
    #export PS4='\[${BLUE}\]$(printf "[%s] @%s " $(date +%T) $LINENO)\[${NORM}\]'
    #export PS4='\[$NORM\]# $(basename ${BASH_SOURCE}):${LINENO}: ${FUNCNAME}(): '
}

LS="$(dirname "${BASH_SOURCE[0]}")"

# Disable variable escaping in shell
shopt -s direxpand

# Determine machine
# This has to happen before other tools are loaded or used, for core::flag
[[ -v WSL_DISTRO_NAME ]] && export WSL=TRUE
case $(hostname) in
*"SchoolLT") export sdev=TRUE ;; # School laptop
*"Desktop") export hdev=TRUE ;;  # Home PC
"server") export server=TRUE ;;  # Server
*) export unknown=TRUE ;; # Anything else
esac

# Provides all "core" functions (warn, error, trace, etc)
# shellcheck disable=SC1091
source "$LS/core.sh"

[[ "$WSL" && ! "$PATH" =~ "Microsoft VS Code" ]] && {
    PATH="$PATH:/mnt/c/Program Files/VSCodium/bin"
}

export PATH

#if [[ "$(sudo -l -U "$USER")" =~ NOPASSWD ]]; then 
#    alias ed='sudo nano'
#else
    alias ed="nano"
#fi

alias .cmds.sh='ed $LS/.cmds.sh'
alias .bashrc='ed $HOME/.bashrc'
alias .loader='ed $LS/.loader.bashrc'

# Very new. Not all machines will have this installed, but use it if it is.
cmdchk eza && alias ls='eza'

alias ll='ls -l'
alias l='ls -CF'
alias c='clear'
alias a='ls -a'
alias ca='c;a'
alias cl='c;ls'
alias la='ls -CFa'
alias ref='exec $SHELL'

###
#* Main imports
###

# shellcheck disable=SC1091
source "$LS/utils/mimp.sh" # Provides 'using' and import commands
source "$LS/.colorsheet.sh"            # Not a module, just variables

using "utils/flags"

# shellcheck disable=SC2034 # emergency_backup_version is used for custom PS1 prompts (./utils/cps)
flag SERVER UNKNOWN && emergency_backup_version="$(git -C "$LS" log -1 --format='%ad' --date=format:'%m.%d.%Y')"

using "command_registry.sh"
using "utils/.temporary.sh"
using "config/config.sh" -f

using "$HOME/.lsconfig.sh" -f # Import user defined configuration [OPTIONAL]
using "debugging/debug_root.sh"

[[ "$DEBUG" ]] && debug # Enable environment debugging

using "utils/colors"
using "utils/happytime.sh"     # A joke command (Figlet)
using "utils/cum"              # Cheap Utility Manager
using "utils/text.sh"          # Provides 'Sprint' and 'array'
using "utils/utils.sh"         # Misc commands for basic operations
using "utils/prompt_setter.sh" # Sets the PS1 prompt (ui)
using "remupd/git-recov.sh"    # Provides 'gitupdate'
cmdchk flyline && {
    using "utils/builtins/flyline.sh"
}

flag WSL && {
    export DOTNET_ROOT="$HOME/.dotnet"
    export DOTNET_CLI_TELEMETRY_OPTOUT="true"
    using "utils/wslutil.sh"
    core::mount_drives
}

using "bashext/bashext.sh"

# Configures additional paths, requires bashext
flag WSL && init_wsl_tools

export DRIVE_BIN="$BACKS/bin"

[[ "$1" == "install" ]] && {
    # shellcheck disable=SC1091
    source "$LS/install.sh" "$2"
}

# Binary characters keep appearing in my main PCs history file.
! grep -qI . ~/.bash_history && {
    core::verbose "Cleaning bash history"
    cat ~/.bash_history | col -b >~/.bash_history.spare
    mv ~/.bash_history.spare ~/.bash_history
}

# Source the independent file for each computer if it's there
using "$HOME/.ind.sh" -f

regload "$LS/.loader.bashrc"
regmod export core
return 0 # Mask return if there was no debug variable
