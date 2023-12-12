#!/bin/bash
_CHECK() { # Most effective way for me to kill the application.
    if [[ $1 == "TRUE" ]]; then
        green
    elif [[ $1 == "FALSE" ]]; then red; else return 1; fi
}

LIST() { # Thought youd come looking for this one
    echo
    magenta
    echo
    echo "  Debug Variables:"
    blue
    (
        set -o posix
        set
    ) | less | grep "__" | grep -v "^PATH" | grep -v "__TEMP__PATH__ARRAY" | grep -v ".CMDS" | grep -v "__VAR__ASSETS" >>$HOME/.TEMP_FILE_69420_HIDDEN
    __VAR__ASSETS=("$(cat "$HOME"/.TEMP_FILE_69420_HIDDEN)")
    [ -f $HOME/.TEMP_FILE_69420_HIDDEN ] && rm $HOME/.TEMP_FILE_69420_HIDDEN
    for item in "${__VAR__ASSETS[@]}"; do # Why do code blocks sometimes look like spaceships?
        if [[ $item == *"TRUE" ]]; then _COL=green; elif [[ $item == *"FALSE" ]]; then _COL=red; else _COL=blue; fi
        echo -ne " "
        yellow
        local _SHIFT=FALSE
        for ((i = 0; i < ${#item}; i++)); do # Youre never going to unsee it now.
            [[ $_SHIFT == FALSE ]] && yellow
            [[ "${item:$i:1}" == "=" ]] && white
            echo -ne "${item:$i:1}"
            [[ "${item:$i:1}" == "=" ]] && $_COL && _SHIFT=TRUE # Youre welcome.
        done
        echo
    done

    echo
    echo
    magenta
    echo " __TEMP__PATH__ARRAY:"
    blue
    _COUNT=0
    _SELECT="├─"
    for item in "${__TEMP__PATH__ARRAY[@]}"; do
        _COUNT=$((_COUNT + 1))
        if [[ $_COUNT == ${#__TEMP__PATH__ARRAY[@]} ]]; then _SELECT="└─"; fi
        if [[ $item == $__PATH__ ]]; then
            echo "  $(green)$_SELECT$(blue)$item  $(yellow)=> $(blue)[$(green)__PATH__$(blue)]"
            THIS=$item
        elif [[ $item == *"HackermanConsole.sh" ]]; then
            echo "  $(green)$_SELECT$(blue)$item  $(yellow)=> $(blue)[$(green)This$(blue)]"
        else
            echo "  $(green)$_SELECT$(blue)$item"
        fi
    done
    unset _SELECT _COUNT
    if [[ $__SHOW_EASTEREGGS == TRUE ]]; then
        yellow
        echo
        echo " Eastereggs:"
        echo "Type 'I want to see you' in first interaction with any of the 'people'"
    fi
    echo
}

WaitFor() {
    local args=$*
    [[ $args == *" -q"* ]] && args=${args// -q/} && local QUIET=TRUE
    $1 &
    PID=$!
    $2 &
    PID2=$!
    $3 &
    PID3=$!
    $4 &
    PID4=$!
    local PID=$!
    while [ -d /proc/$PID ] || [ -d /proc/$PID2 ] || [ -d /proc/$PID3 ] || [ -d /proc/$PID4 ]; do
        if [[ $QUIET != TRUE ]]; then
            echo -ne 'Loading [-]\r'
            sleep .1
            echo -ne 'Loading [\]\r'
            sleep .1
            echo -ne 'Loading [|]\r'
            sleep .1
            echo -ne 'Loading [/]\r'
        fi
        sleep .1
    done
    green
    [[ $QUIET == TRUE ]] || echo -ne 'Complete         \r'
    white
}

dec() {
    if [[ $1 == "not" ]]; then
        [[ ${!2} == TRUE ]] && eval $2=FALSE && _DONE=TRUE
        [[ $_DONE != TRUE ]] && [[ ${!2} == FALSE ]] && eval $2=TRUE
    elif [[ $1 != "" ]] && [[ $2 == "" ]]; then
        echo $(red)Data for variable needed.
    elif [[ $1 != "" ]] && [[ $2 != "" ]]; then
        eval $1=$2
    fi
}

rem() {
    if [[ $1 != "" ]]; then
        if [[ -v $1 ]]; then
            unset $1
        else # Look how simple this one is!
            echo $(red)Variable does not exist
        fi
    fi
}

_DONT_GO() { # Why leave? Its a "GrEaT" game
    if [[ $__STOP__EXIT == TRUE ]]; then
        sleep 1
        if [[ $_DONT_DONE == FALSE ]]; then
            echo
            Sprint "Why leave?"
            echo
            _GO
        elif [[ $_DONT_DONE == TRUE ]]; then
            echo
            Sprint "Fine."
            _GO
            sleep 1
            exit
        fi
        _DONT_DONE=TRUE
    fi
}

FETCH_DEVICE() { # This is mostly for asthetic purposes.

    dpkg -s jq >/dev/null 2>&1 || sudo apt-get install jq -y >/dev/null 2>&1
    dpkg -s dmidecode >/dev/null 2>&1 || sudo apt-get install dmidecode >/dev/null 2>&1

    echo Fetching device manufacturer...
    manufacturer=$(cat /sys/class/dmi/id/chassis_vendor 2>/dev/null) || manufacturer="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $manufacturer == "" ] && manufacturer="Unknown"
        [ $manufacturer == "Unknown" ] && echo "$(red)$manufacturer$(white)"
        [ $manufacturer == "Unknown" ] || echo "$(green)$manufacturer$(white)"
    fi

    echo Fetching device model...
    product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null) || product_name="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $product_name == "" ] && product_name="Unknown"
        [ $product_name == "Unknown" ] && echo "$(red)$product_name$(white)"
        [ $product_name == "Unknown" ] || echo "$(green)$product_name$(white)"
    fi

    echo Fetching device version...
    version=$(cat /sys/class/dmi/id/bios_version 2>/dev/null) || version="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $version == "" ] && version="Unknown"
        [ $version == "Unknown" ] && echo "$(red)$version$(white)"
        [ $version == "Unknown" ] || echo "$(green)$version$(white)"
    fi

    echo Fetching device serial number...
    serial_number=$(cat /sys/class/dmi/id/product_serial 2>/dev/null) || serial_number="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $serial_number == "" ] && serial_number="Unknown"
        [ $serial_number == "Unknown" ] && echo "$(red)$serial_number$(white)"
        [ $serial_number == "Unknown" ] || echo "$(green)$serial_number$(white)"
    fi

    echo Fetching device UUID...
    hostname=$(hostname 2>/dev/null) || hostname="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $hostname == "" ] && hostname="Unknown"
        [ $hostname == "Unknown" ] && echo "$(red)$hostname$(white)"
        [ $hostname == "Unknown" ] || echo "$(green)$hostname$(white)"
    fi

    echo Fetching device OS...
    operating_system=$(hostnamectl 2>/dev/null | grep "Operating System" 2>/dev/null | cut -d ' ' -f5- 2>/dev/null) && [[ operating_system == "" ]] && operating_system="Unknown"
    if [[ $operating_system == "" ]]; then
        operating_system="Unknown"
    fi
    if [[ "$1" == "-O" ]]; then
        [ $operating_system == "Unknown" ] && echo "$(red)$operating_system$(white)"
        [ $operating_system == "Unknown" ] || echo "$(green)$operating_system$(white)"
    fi

    echo Fetching device architecture...
    architecture=$(arch 2>/dev/null) || architecture="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $architecture == "" ] && architecture="Unknown"
        [ $architecture == "Unknown" ] && echo "$(red)$architecture$(white)"
        [ $architecture == "Unknown" ] || echo "$(green)$architecture$(white)"
    fi

    echo Fetching device CPU...
    processor_name=$(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo 2>/dev/null | uniq 2>/dev/null | sed -e 's/^[ \t]*//' 2>/dev/null) || processor_name="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $processor_name == "" ] && processor_name="Unknown"
        [ $processor_name == "Unknown" ] && echo "$(red)$processor_name$(white)"
        [ $processor_name == "Unknown" ] || echo "$(green)$processor_name$(white)"
    fi

    echo Fetching device memory size...
    memory=$(dmidecode -t 17 2>/dev/null | grep "Size.*MB" 2>/dev/null | awk '{s+=$2} END {print s / 1024"GB"}' 2>/dev/null)
    if [[ $memory == "" ]] || [[ $memory == "0"* ]]; then
        memory="Unknown"
    fi
    if [[ "$1" == "-O" ]]; then
        [ $memory == "Unknown" ] && echo "$(red)$memory$(white)"
        [ $memory == "Unknown" ] || echo "$(green)$memory$(white)"
    fi

    echo Fetching device disk model...
    hdd_model=$(cat /sys/block/sda/device/model 2>/dev/null) || hdd_model="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $hdd_model == "" ] && hdd_model="Unknown"
        [ $hdd_model == "Unknown" ] && echo "$(red)$hdd_model$(white)"
        [ $hdd_model == "Unknown" ] || echo "$(green)$hdd_model$(white)"
    fi

    echo Fetching device screen colombs...
    screen_columbs=$(tput cols)
    if [[ "$1" == "-O" ]]; then
        [ $screen_columbs == "" ] && screen_columbs="Unknown"
        [ $screen_columbs == "Unknown" ] && echo "$(red)$screen_columbs$(white)"
        [ $screen_columbs == "Unknown" ] || echo "$(green)$screen_columbs$(white)"
    fi

    echo Fetching device screen lines...
    screen_lines=$(tput lines)
    if [[ "$1" == "-O" ]]; then
        [ $screen_lines == "" ] && screen_lines="Unknown"
        [ $screen_lines == "Unknown" ] && echo "$(red)$screen_lines$(white)"
        [ $screen_lines == "Unknown" ] || echo "$(green)$screen_lines$(white)"
    fi

    echo Fetching device screen size...
    Sq1=$((screen_columbs ^ screen_columbs))
    Sq2=$((screen_lines ^ screen_lines))
    screen_size=$(bc <<<"scale=0; sqrt($Sq1 + $Sq2)")

    [ $screen_size == "0" ] && echo "$(red)ERROR_DOING_MATH$(white)" && screen_size="ERROR_DOING_MATH"
    if [[ "$1" == "-O" ]]; then
        [ $screen_size == "" ] && screen_size="Unknown"
        [ $screen_size == "Unknown" ] && echo "$(red)$screen_size$(white)"
        [ $screen_size == "ERROR_DOING_MATH" ] && echo "$(red)$screen_size$(white)" && screen_size="Unknown" && local SWI=TRUE
        [ $screen_size == "Unknown" ] || echo "$(green)$screen_size$(white)"
        [ $SWI == TRUE ] && screen_size="ERROR_DOING_MATH"
    fi

    echo Fetching device IP...
    system_main_ip=$(hostname -I 2>/dev/null) || system_main_ip="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $system_main_ip == "" ] && system_main_ip="Unknown"
        [ $system_main_ip == "Unknown" ] && echo "$(red)$system_main_ip$(white)"
        [ $system_main_ip == "Unknown" ] || echo "$(green)$system_main_ip$(white)"
    fi

    echo Fetching device public IP...
    system_public_ip=$(curl -s https://api.ipify.org 2>/dev/null) || system_public_ip="Unknown"
    if [[ "$1" == "-O" ]]; then
        [ $system_public_ip == "" ] && system_public_ip="Unknown"
        [ $system_public_ip == "Unknown" ] && echo "$(green)$system_public_ip$(white)"
        [ $system_public_ip == "Unknown" ] || echo "$(red)$system_public_ip$(white)"
    fi

    echo Checking if device is managed...
    is_a_managed_device=$(wget -q -O - pastebin.com)
    if [[ $is_a_managed_device == *"iboss"* ]]; then
        is_a_managed_device="TRUE"
    elif [[ $is_a_managed_device == "" ]]; then
        is_a_managed_device="Unknown"
    else
        is_a_managed_device="FALSE"
    fi

    if [[ "$1" == "-O" ]]; then
        [ $is_a_managed_device == "" ] && is_a_managed_device="Unknown"
        if [[ $is_a_managed_device == "Unknown" ]] || [[ $is_a_managed_device == "FALSE" ]]; then
            echo "$(red)$is_a_managed_device$(white)"
        else
            echo "$(green)$is_a_managed_device$(white)"
        fi
    fi

    printf '{"UserData":{"manufacturer":"%s","product_name":"%s","version":"%s","serial_number":"%s","hostname":"%s","username":"%s","operating_system":"%s","architecture":"%s","processor_name":"%s","memory":"%s","hdd_model":"%s","system_main_ip":"%s","system_public_ip":"%s","managed_device":"%s","screen_columbs":"%s","screen_lines":"%s","screen_size":"%s"}}' "$manufacturer" "$product_name" "$version" "$serial_number" "$hostname" "$USER" "$operating_system" "$architecture" "$processor_name" "$memory" "$hdd_model" "$system_main_ip" "$system_public_ip" "$is_a_managed_device" "$screen_columbs" "$screen_lines" "$screen_size" >"$__CMDS/.Device.json"

    local TEMP=$(cat $__CMDS/.Device.json)
    echo $TEMP | jq >$__CMDS/.Settings.json
    echo
    echo $(green)Fetch complete.$(white)
    if [[ $1 == "-o" ]]; then
        cat $__CMDS/.Settings.json
    fi
    rm $__CMDS/.Device.json

}

_ENC_() {
    local IN="$*"
    [[ $IN == *" -ns"* ]] && SAVE=FALSE
    IN=${IN// -ns/}
    local _HEX=$(echo -n "$IN" | xxd -ps | sed 's/[[:xdigit:]]\{2\}/\\x&/g')
    #echo $_HEX
    local _HEX=${_HEX//\\/ }
    local _HEX=${_HEX//x/}
    local _HEX_A=($_HEX)
    local OUTPUT=
    for number in "${_HEX_A[@]}"; do
        LET="$(echo $number | sed 's/[0-9g-z\\]//g')"
        if [[ $LET != "" ]]; then
            number=${number//$LET/}
            if [[ $number -gt 5 ]]; then
                number=$((number - 4))
            else
                number=$((number + 4))
            fi
            OUTPUT+="\\x$number$LET"
        else
            [[ $number -gt 9 ]] && number=$((number + 11))
            OUTPUT+="\\x$number"
        fi
    done
    #echo $OUTPUT
    [[ $SAVE != FALSE ]] && echo -ne "$OUTPUT" >$__CMDS/.Encrypted.enc
    [[ $SAVE == FALSE ]] && echo $OUTPUT
    #cat $__CMDS/.Encrypted.enc | xxd -ps | sed 's/[[:xdigit:]]\{2\}/\\x&/g'
}

_ENC_FILE() {
    if [[ $1 == " -c" ]]; then
        FILE=$(cat ${!2})
        [[ $* == *" -ns"* ]] && SAVE=FALSE
        _ENC_ $FILE
        SAVE=TRUE
    elif [[ -f "$__CMDS/$1" ]]; then
        FILE=$(cat $__CMDS/$1)
        [[ $* == *" -ns"* ]] && SAVE=FALSE
        _ENC_ $FILE
        SAVE=TRUE
    fi
}

_DEC_() {
    ARGS="$*"
    if [[ $1 == "" ]]; then
        ARGS=$(cat $__CMDS/.Encrypted.enc | xxd -ps | sed 's/[[:xdigit:]]\{2\}/\\x&/g')
    else
        echo $ARGS
        ARGS=$(echo $ARGS | xxd -ps | sed 's/[[:xdigit:]]\{2\}/\\x&/g')
    fi
    ARGSs=${ARGS//\\/ }
    ARGSs=${ARGSs//x/}
    A_ARGS=($ARGSs)
    for number in "${A_ARGS[@]}"; do
        LET="$(echo $number | sed 's/[0-9g-z\\]//g')"
        if [[ $LET != "" ]]; then
            number=${number//$LET/}
            if [[ $number -gt 5 ]]; then
                number=$((number - 4))
            else
                number=$((number + 4))
            fi
            OUTPUT+="\\x$number$LET"
        else
            [[ $number -gt 20 ]] && number=$((number - 11))
            OUTPUT+="\\x$number"
        fi
    done
    echo -e ${OUTPUT// /}
}
