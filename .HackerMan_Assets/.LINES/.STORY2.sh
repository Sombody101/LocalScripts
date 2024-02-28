#!/bin/bash
STORY_LINE_2() {
    LINE=TRUE
    blue
    cat $__PATH__/HackermanAsset_01
    sleep 2
    Sprint "How was the journey here?"
    
    white
    listen reply
    blue
    
    if [[ $reply == "I want to see you" ]]; then
        Sprint "Me too?"
        sleep .3
        Sprint "Ummm..."
        Sprint "Nothing..."
        sleep .2
        c
        Sprint "I didnt say anything, dont worry."
        Sprint "Let me see if I can do that."
        sleep 3
        Sprint "Found it!"
        sleep 3
        cat $__PATH__/Script_API_V2-44.EXE
        sleep 5
        blue
        Sprint "There..."
        c
        Sprint "Enough of that..."
        Sprint "Lets move on with the game."
        sleep 2
    else
        Sprint "Good!"
        Sprint "Always great to see people have a $reply time getting to this part!"
        sleep 1
        Sprint "My AI is still being developed, so sorry if that sounded like a strange"
        Sprint "or abnormal thing to say."
        sleep 1
        Sprint "Lets move on..."
        sleep 2
    fi
    c
    Sprint "Lets start off with easy questions!"
    Sprint "Question 1: "
    Sprint "   $(green) 1 * 3 = ?$(blue) "
    _SCORE=0
    sleep .1
    
    listen _ANS1
    blue
    if [[ $_ANS1 == "3" ]]; then
        _SCORE=$((_SCORE + 1))
        Sprint "Great!"
    else
        Sprint "Oh no!"
        Sprint "That wasn't correct!"
    fi
    Sprint "Score: $_SCORE"
    sleep 1
    Sprint "Question 2"
    Sprint "    $(green)5 * 2 = ? $(blue)"
    
    listen _ANS2
    blue
    if [[ $_ANS2 == "10" ]]; then
        _SCORE=$((_SCORE + 1))
        Sprint "Great!"
    else
        Sprint "Oh no!"
        Sprint "That wasn't correct!"
    fi
    Sprint "Score: $_SCORE"
    sleep 1
    blue
    Sprint "Question 3"
    Sprint "    $(green)((50229 * (442^22)) + (404022^12 + 5)) * 5 = ?$(blue)"
    
    listen _ANS3
    blue
    Sprint "Oh no!"
    Sprint "That wasn't correct!"
    red
    LINE=
    echo -ne " Score: 0 \r" # 8
    sleep 4
    echo -ne ' Sc四re: 0 \r'
    sleep .5
    echo -ne ' Sc四二e: 0 \r'
    sleep .5
    echo -ne ' S末四二e: 0 \r'
    sleep .5
    echo -ne ' S末四二e: 明 \r'
    sleep .5
    echo -ne ' 林末四二e: 明 \r'
    sleep .5
    echo -ne ' 林末四二六: 明 \r'
    sleep .5
    echo -ne ' 林末四二六十 明 \r'
    sleep .5
    echo
    echo
}
