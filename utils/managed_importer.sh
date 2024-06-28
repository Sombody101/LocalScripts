#!/bin/bash

MANAGED_LOADED=()

add_managed_import() {
    : "managed_importer.sh: add_managed_import"
    : "<arg1> : Status code"
    : "<arg2> : Message"
    : "[arg2 == {$NULL} => arg2<=>arg1]"

    local status=1
    local message

    if [[ ! "$2" ]]; then
        # only one argument, assume it's good
        message="$1"
    else
        status="$1"
        message="$2"
    fi

    case $status in
    0) {
        status="${BLUE}[FOUND]"
    };;
    1) {
        status="${RED}[NOT F]"
    } ;;
    2) {
        status="${RED}[NOT*F]"
    } ;;
    esac

    MANAGED_LOADED+=("$status $message")
}

# Same as 'loaded', but less involvment
alias mimports='array MANAGED_LOADED'

LOADED=()

regload() {
    LOADED+=("[$MAGENTA+$NORM]:  $*")
}

regnload() {
    LOADED+=("[$RED-$NORM]:  $*")
}

alias loaded='array LOADED'

track() {
    local cmd="$1"
    shift

    : "${CYAN}ENTER: $YELLOW$cmd$CYAN :ENTER$NORM"
    $cmd "$@"
    local ret="$?"
    : "${CYAN}ENTER: $YELLOW$cmd$CYAN :EXIT$NORM"

    # return commands code
    return "$ret"
}
