#!/bin/bash
TASK_FILE="$BACKS/TASKLIST/TASKLIST.tsk" # .tsk => .task

regload "$BACKS/TASKLIST/TASKLIST.sh"

tl() {
    [[ $* == "" ]] && {
        [ ! -f "$TASK_FILE" ] && {
            warn "Check if $TASK_FILE has been deleted or moved"
            return 1
        }

        read -ra arr <<< $(cat $TASK_FILE)

        return 0
    }

    printf '[%s] %s' "$(date)" "$*" >>"$TASK_FILE"
    echo -ne "\n" >>"$TASK_FILE"
}

ctl() {
    case "$1" in
    -f)
        warn "Clearing $TASK_FILE"
        rm "$TASK_FILE" && {
            echo "$TASK_FILE cleared."
            : >"$TASK_FILE"
            return 0
        } || {
            warn "Failed to clear $TASK_FILE (Check if it still exists or has been moved)"
            return 1
        }
        ;;
    *)
        read -rp "Are you sure you want to clear all tasks? [Y/N]: " confirm
        if [[ $confirm == "Y" ]]; then
            warn "Clearing $TASK_FILE"
            rm "$TASK_FILE" && {
                echo "$TASK_FILE cleared."
                : >"$TASK_FILE"
                return 0
            } || {
                warn "Failed to clear $TASK_FILE (Check if it still exists or has been moved)"
                return 1
            }
        fi
        ;;
    esac
}
