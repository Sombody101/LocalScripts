#!/bin/bash

#####################################################################################
# Before you go looking through this, please know that im still new to bash script. #
# If you yourself are new to bash script...                                         #
# Then ingnore the first sentence, this is pro language.                            #
# And as you know, am pro.                                                          #
#####################################################################################

# Booleans are represented as "TRUE"/"FALSE"
# All functions are looking for all caps

__DEBUG=TRUE # Shows all variables related to __PATH__, and enables cool commands
__SHOW_EASTEREGGS=FALSE
_WELCOME=FALSE
_DONT_DONE=FALSE
__STOP__EXIT=FALSE
__PREF="/"

black() { tput setaf 0; }
red() { tput setaf 1; }
green() { tput setaf 2; }
yellow() { tput setaf 3; }
blue() { tput setaf 4; }
magenta() { tput setaf 5; }
cyan() { tput setaf 6; }
white() { tput setaf 7; }
norm() { tput sgr0; }
c() { clear; }

# _STOP: Prevents user input while text is being appended.
_STOP() { if [ -t 0 ]; then stty -echo -icanon time 0 min 0; fi; }
# _GO: Enables user input (Also fixes _STOP when game ends unexpectedly)
_GO() { if [ -t 0 ]; then stty sane; fi; }

# LEAVE: What do you think it does? Read the name...
#LEAVE() { _GO; kill -9 "$(ps -ef | grep HackermanConsole.sh | grep -v grep | awk '{print $2}')" 1> /dev/null; }
LEAVE() {
    _GO
    pkill -9 -f HackermanConsole.sh >/dev/null
}

if [[ $__STOP__EXIT == TRUE ]]; then
    trap _DONT_GO SIGINT
fi

# Random names in hopes they're not used in game
__-_SOURCES() { # Any commands still in this file cant be moved into libraries... So this is their home.
    echo reached
    for item in $__CMDS/.* $__STORE/.*; do
        if [[ $item == *".sh" ]]; then
            echo "$item"
            source "$item" || echo "$(red)Failed to fetch resourse $item $(white)"
        fi
    done # You think this is chaotic? You should go see what is inside the "LIST" command <LIB1/LIST>
}

listen() { # Allows the app to filter out any commands
    _GO
    echo -en "$(white)> "
    read -r $1
    if [[ "${!1}" == "exit" ]]; then
        LEAVE
        sleep 5
        echo "$(red)Error stopping application: CTRL+C might be needed"
    fi
    if [[ "${!1}" == $__PREF* ]] || [[ "${!1}" == ">"* ]] && [[ $__DEBUG == TRUE ]]; then
        local __OP=${!1}
        __OP="${__OP//$__PREF/}"
        if [[ $__OP == "echo" ]]; then
            echo "$(echo "$@" | sed "s/^[^ ]* //")"
        else
            $__OP 2>/dev/null || echo "$(red)Unknown command: $(yellow)$__OP"
        fi
        white
        listen $1
    fi
    _STOP
}

# One of the most important commands to this application. Tampering with it could screw everything up.
# It was difficult enough for me to navigate it, and Im the one that made it lol
if [[ $__PATH__ != "" ]]; then # If __PATH__ is preset:
    __TEMP=$(pwd)
    red
    cd "$__PATH__" && __=TRUE || {
        echo "$(red)Ensure custom path to game assets exists or is correct. (Start with \'/\' if needed)"
        echo "Use '$(cyan)export$(red)' to create the __PATH__ variable."
    }
    if [[ $__ == TRUE ]]; then
        #__SERV="$($(pwd)/ServerHostRunner.EXE | ${__SERV//.\//\/})"
        __TEMP__PATH__ARRAY=$(find . | grep ".HackerMan_Assets" | grep -v ".CMDS")
        __FOUND=TRUE
        __SERV="$(find . | grep ".HackerMan_Assets")"
        __SERV="/home${__SERV//.\//\/}"
        __CMDS="$__PATH__/.CMDS"
        __STORE="$__PATH__/.LINES"
    fi

    if [[ $__ == FALSE ]]; then
        cd "$__TEMP" || exit
    fi
else # If __PATH__ needs to be found manually (Only works when within the $HOME directory [ROOT/home/USER] => $HOME):
    cd "/home" || cd "$HOME/.."
    __TEMP__PATH="$(find . | grep ".HackerMan_Assets" | grep -v ".CMDS" | grep -v ".LINES" | grep -v "ref")"
    __TEMP__PATH="${__TEMP__PATH//.\//\/}"
    __TEMP__PATH__ARRAY=($__TEMP__PATH)
    for ((i = 0; i < ${#__TEMP__PATH__ARRAY[@]}; i++)); do
        __TEMP__PATH__ARRAY[i]="/home${__TEMP__PATH__ARRAY[$i]}"
    done
    __PATH__=${__TEMP__PATH__ARRAY[0]}
    export __PATH__
    __SERV="$(find . | grep ".HackerMan_Assets")" && __FOUND=TRUE
    __SERV="/home${__SERV//.\//\/}"
    __CMDS="$__PATH__/.CMDS"
    __STORE="$__PATH__/.LINES"

fi

__-_SOURCES
_FETCH_DEVICE &>/dev/null &
c # c => clear

if [[ $__FOUND == "" ]]; then
    echo "$(red)Startup failed. Please ensure '.HackerMan_Assets' is within your '$HOME' directory."
    echo "$(white)Use '$(cyan)export$(white)' to create the __PATH__ variable."
    LEAVE @ >/dev/null
elif [[ $__FOUND == TRUE ]]; then
    c
    yellow
    echo "If the game ends unexpectedly and your shell wont show any text that you're trying to type, dont panic!"
    echo "Type '_GO', then enter. You wont see it being typed, but it will fix the issue."
    echo "Use 'exit' to exit"
    echo
    echo "Press enter to play."

    if [[ $__DEBUG == TRUE ]]; then
        LIST
    else
        LIST >/dev/null
    fi

    echo "$THIS"
    white
    listen _PLAY
    unset _PLAY
    _STOP

    c
    sleep 2

    _INTRO__ || echo Failed to start... Please run the file again.
    if [[ "$Input" == SKIP ]]; then
        STORY_LINE_2
    else
        STORY_LINE_1
        STORY_LINE_2
        #STORY_LINE_3
    fi
fi

_GO
unset _STOP # Just to be sure that _STOP cant be used to block user input even after the game ends.
