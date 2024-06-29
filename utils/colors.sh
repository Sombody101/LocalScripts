#!/bin/bash
#tput setab [1-7] – Set a background color using ANSI escape
#tput setb [1-7] – Set a background color
#tput setaf [1-7] – Set a foreground color using ANSI escape
#tput setf [1-7] – Set a foreground color
#~~~
#tput bold – Set bold mode
#tput dim – turn on half-bright mode
#tput smul – begin underline mode
#tput rmul – exit underline mode
#tput rev – Turn on reverse mode
#tput smso – Enter standout mode (bold on rxvt)
#tput rmso – Exit standout mode
#tput sgr0 – Turn off all attributes
#~~~
#0 – Black
#1 – Red
#2 – Green
#3 – Yellow
#4 – Blue
#5 – Magenta
#6 – Cyan
#7 – White

# Text colors
black() {
    tput setaf 0
}

red() {
    tput setaf 1
}

green() {
    tput setaf 2
}

yellow() {
    tput setaf 3
}

blue() {
    tput setaf 4
}

magenta() {
    tput setaf 5
}

cyan() {
    tput setaf 6
}

white() {
    tput setaf 7
}

if test -t 1 || [[ "$FORCE_COLOR" ]]; then
    export BLACK="$(black)"
    export RED="$(red)"
    export GREEN="$(green)"
    export YELLOW="$(yellow)"
    export BLUE="$(blue)"
    export MAGENTA="$(magenta)"
    export CYAN="$(cyan)"
    export WHITE="$(white)"
fi
# red, orange, yellow, green, blue, indigo, and violet

alias _red='echo -ne "\e[38;2;255;0;0m"'
alias _orange='echo -ne "\e[38;2;255;165;0m"'
alias _yellow='echo -ne "\e[38;2;255;255;0m"'
alias _green='echo -ne "\e[38;2;0;128;0m"'
alias _blue='echo -ne "\e[38;2;0;0;255m"'
alias _indigo='echo -ne "\e[38;2;75;0;130m"'
alias _violet='echo -ne "\e[38;2;148;0;211m"'

# Highlighted
,black() {
    tput smso
    black
}

,red() {
    tput smso
    red
}

,green() {
    tput smso
    green
}

,yellow() {
    tput smso
    yellow
}

,blue() {
    tput smso
    blue
}

,magenta() {
    tput smso
    magenta
}

,cyan() {
    tput smso
    cyan
}

,white() {
    tput smso
    white
}

# Undo highlight
.black() {
    tput rmso
    black
}

.red() {
    tput rmso
    red
}

.green() {
    tput rmso
    green
}

.yellow() {
    tput rmso
    yellow
}

.blue() {
    tput rmso
    blue
}

.magenta() {
    tput rmso
    magenta
}

.cyan() {
    tput rmso
    cyan
}

.white() {
    tput rmso
    white
}

# Accents
bold() {
    tput bold
}

underline() {
    tput smul
}

,underline() {
    tput rmul
}

dim() {
    tput dim
}

rev() {
    tput rev
}

# Reset
norm() {
    tput sgr0
}

export NORM=$(norm)

# using "utils/ColorSheet.sh"
