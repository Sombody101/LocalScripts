#!/bin/bash
_INTRO__() {
    if [[ $_WELCOME == TRUE ]]; then
        white
        echo Welcome.
        sleep 2
        echo To get things started, lets do a quick peripheral test.
        sleep 2
        echo Please press $(green)ENTER
        listen _FALSE_VAR
        echo Analyzing input...
        sleep 3
        echo Input was \"$_FALSE_VAR\"
        sleep 3
        echo This concludes our test.
        sleep 3
    fi
    c
    red
    go=true
    sleep 1
    COUNT=0
    while [[ "$go" == "true" ]]; do
        echo -ne ' [LOADING - ]                       \r'
        sleep .5
        echo -ne ' [LOADING \ ]                       \r'
        sleep .5
        echo -ne ' [LOADING | ]                       \r'
        sleep .5
        echo -ne ' [LOADING / ]                       \r'
        sleep .5
        COUNT=$((COUNT + 1))
        if [[ $COUNT -eq 3 ]]; then unset go; fi
    done
    echo
    echo

    # Intro
    LINE=FALSE
    red
    c
    LINE=TRUE
    Sprint "Welcome."
    sleep 1
    Sprint "Want to play a game? [y/n]"
    white
    listen Input
    red
    if [[ $Input == "I want to see you" ]]; then
        Sprint "Oh..."
        sleep 1
        Sprint "Nobody has ever asked me that before..."
        sleep 1
        Sprint "Im not too sure how to do this."
        sleep 3
        Sprint "I think I got it."
        sleep 1
        cat $__PATH__/Scanner.EXE
        red
        sleep 5
        c
        Sprint "No more of that..."
        sleep 1
        Sprint "Now, lets play that game."
        ENABLED=TRUE
    elif [[ $Input == *"y"* ]]; then
        Sprint "Great!"
        Sprint "Let the games commence..."
        ENABLED=TRUE
    elif [[ $Input == "SKIP" ]]; then
        echo "Skipping..."
        ENABLED=TRUE
    else
        LINE=
        Sprint "Too bad..."
        sleep 1
        LINE=TRUE
        Sprint " What a shame."
        sleep 2
        Sprint "Goodbye"
        echo "You're dead to me now"
        sleep .01
        c
        exit
    fi
}
