#!/bin/bash
STORY_LINE_1() {
    if [[ $ENABLED == TRUE ]]; then
        echo
        go=true
        sleep 1
        COUNT=0
        while [[ "$go" == "true" ]]; do
            echo -ne ' Processing Triggers   \r'
            sleep .5
            echo -ne ' Processing Triggers.  \r'
            sleep .5
            echo -ne ' Processing Triggers.. \r'
            sleep .5
            echo -ne ' Processing Triggers...\r'
            sleep .5
            COUNT=$(($COUNT + 1))
            if [[ $COUNT -eq 3 ]]; then
                unset go
                green
                echo -ne ' COMPLETE                     \r'
            fi
        done
        echo
        red
        echo
        echo Test request [$(yellow)https://rr.noordstar.me/game-cs-dc988d68$(red)]
        sleep 3
        echo
        echo Test end
        echo "    Ressult: $(green)SUCCESS "
        red
        echo
        sleep 2
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[7%] '$(red)'      \r'
        sleep 2
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[12%]'$(red)'      \r'
        sleep 1
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[23%]'$(red)'      \r'
        sleep 1.2
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[24%]'$(red)'      \r'
        sleep 3
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[19%]'$(red)'      \r'
        sleep 3
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[53%]'$(red)'      \r'
        sleep 1
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[78%]'$(red)'      \r'
        sleep 1
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[92%]'$(red)'      \r'
        sleep 2
        echo -ne ' Fetching "'$(yellow)'Game.cs'$(red)'" '$(yellow)'[99%]'$(red)'      \r'
        echo
        echo -ne ' Loading Complete.'
        sleep 2
        wget -q -O - http://pastebin.com # > $HOME/pastebin.wget
        sleep .2
        c
        wget -q -O - http://canvas.com # > $HOME/canvas.wget
        sleep .2
        c
        wget -q -O - https://blooket.com # > $HOME/blooket.wget
        sleep .2
        c
        wget -q -O - http://dotnetfiddle.net # > $HOME/dotnetfiddle.wget
        sleep .2
        c
        sleep .1
        blue
        sleep 2
        c
        sleep 1
        c
    fi
}
