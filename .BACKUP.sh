#!/bin/bash

NULL=/dev/null
alias grep='grep --color=auto'
FILE=".BACKUP.sh"
export COLORTERM=truecolor

newnav() {
    : ".BACKUPS: newnav"
    [[ $1 == "" ]] && {
        warn No arguments provided
        return 1
    }

    [[ $2 == "" ]] && {
        warn No path provided
        return 1
    }

    local name=$1
    local path=$2
    shift 2

    eval "
    $name() {
        cd \"$path\"/\$(pathify \$*) || warn \"Failed to locate \$(pathify \$*)\";
    }
    "
}

occ() {
    : ".BACKUPS: occ"
    while :; do
        form -a $*
    done
}

pathify() {
    : ".BACKUPS: pathify"
    IFS="/"
    echo "$*"
    unset IFS
}

warn() {
    : ".BACKUPS: warn"
    echo -ne "$(trace): $(red)$*$(norm)\n"
}

addPath() {
    : ".BACKUPS: addPath"
    [[ "$1" == "" ]] && {
        warn "No path given to add to \$PATH"
        return 1
    }

    [[ ! $PATH =~ $1 ]] && export PATH="$1:$PATH"
}

showPath() {
    : ".BACKUPS: showPath"
    tr ':' '\n' <<<"$PATH"
}

BACKS="$DRIVE/.BACKUPS/.LOADER"
[ -v EMERGENCY_SD_VERSION ] && BACKS="$HOME/LocalScripts/.EMERGENCY_BACKUPS"
CST="$BACKS/cstools"
CST_M="$CST/cstools.main.sh"
ST="$BACKS/site-tools/site-tools.sh"
GC="$BACKS/git_cmds/git_cmds.sh"
APPS="$BACKS/.apps"

qunalias() { unalias "$1" 2>$NULL; }

# Support issues with pre-summer devices (requires unalias)
qunalias drive
qunalias home
qunalias main
newnav backs "$BACKS"
newnav drive "$DRIVE"
newnav home "$HOME"
newnav main "/"

newnav cst "$CST"
newnav ... "$DRIVE/..."

using "$BACKS/.COMMAND_PARSER.sh"
using "$BACKS/.UTILS.sh"
#using "$BACKS/.EXTRAS.sh"
nloaded "$BACKS/.EXTRAS.sh (Unused)"
using "$BACKS/TASKLIST/TASKLIST.sh"
using "$CST_M"
using "$GC" # -f # The file gets sourced, but using logs a "File Not Found" error, so -f
using "$ST"
using "$BACKS/SHOWCASE.sh"

[ ! -v EMERGENCY_SD_VERSION ] && using "$BACKS"/.EMERGENCY_FUNCTIONS_MODULE/.EMERGENCY_SD_FAILURE.sh

addPath "$DRIVE/.BACKUPS/.LOADER/bin"
[ -d "$APPS" ] && addPath "$APPS"
loaded "bin.apps ($DRIVE)"

# Cleanup
unset newNav qunalias

# Register file
loaded "$BACKS/.BACKUP.sh"

vs() {
    : ".BACKUPS: vs"
    local inp="$*"
    [[ "$inp" == "" ]] && inp="."
    (code "$inp" &)
}

__padRight() {
    : ".BACKUPS: __padRight"
    printf '\e[34m%-16s\e[33m%s\e[32m' "$(hostname)" "($1)" >"$HOME"/.__TEMP_INFO.INFO
}

__padLeft() {
    : ".BACKUPS: __padLeft"
    printf '%s%*s' "\e[35m[$1]" "$(($2 - ${#1}))" ""
}

# Better to use the command "basename"
GetName() {
    : ".BACKUPS: GetName"
    [[ "$*" == "" ]] && warn "No files provided" && return 1
    local DRIVE
    local NUM=0
    local FOLD=""

    DRIVE=$(GetDrive -o)
    for folder in "$DRIVE"/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq "$1" ] && FOLD=${folder//$DRIVE\/.BACKUPS/} && FOLD=${FOLD//\//} && echo "$FOLD" && return 0
            NUM=$((NUM + 1))
        fi
    done
    return 1
}

RemoveLast() {
    : ".BACKUPS: RemoveLast"
    echo "${1%/*}"
}

GetDrive() {
    : ".BACKUPS: GetDrive"
    local ARGS="$*"
    for letter in {a..z}; do
        if [ -d /mnt/"$letter"/.BACKUPS/ ]; then
            [[ $ARGS == *"-o"* ]] && echo /mnt/"$letter" && return 0
            [[ $ARGS == *"-O"* ]] && DRIVE=/mnt/$letter && echo "$DRIVE" && return 0
            DRIVE=/mnt/$letter && return 0
        fi
    done
    [[ $ARGS == *"-q" ]] && warn "Unable to find drive" && return 1
}

GetDate() {
    : ".BACKUPS: GetDate"
    DATE=$(date +"%Y/%m/%d %T")
    DATE=${DATE//\//:}
    DATE=${DATE// /_}
    [[ $* == *"-o"* ]] && echo "$DATE" && unset DATE
}

# These functions will soon become obsolete as a C# implementation is underway
backup() {
    : ".BACKUPS: backup"
    local text="$*"
    GetDate
    GetDrive
    [[ $DRIVE == "" ]] && {
        warn No SDCard
        return 1
    }

    mkdir "$DRIVE"/.BACKUPS/"$DATE" || warn Failed to create backup directory "$DRIVE"/"$DATE"
    cp -r "$HOME"/LocalScripts "$DRIVE"/.BACKUPS/"$DATE" || warn Failed to copy LocalScripts "$DRIVE"/"$DATE"
    cp "$HOME"/.bashrc "$DRIVE"/.BACKUPS/"$DATE" || warn Failed to copy .bashrc to "$DRIVE"/"$DATE"
    __padRight backup
    [[ $text != "" ]] && text="\n\e[96m  $text"
    echo -ne "\e[33m$(date) \e[90m:: $(cat "$HOME"/.__TEMP_INFO.INFO)$text" >"$DRIVE"/.BACKUPS/"$DATE"/.BACKUP.INFO
    rm "$HOME"/.__TEMP_INFO.INFO
    echo "$(green)"Backed up .bashrc and LocalScripts to "$DRIVE"/.BACKUPS/"$DATE"
    unset DATE
}

backups() {
    : ".BACKUPS: backups"
    GetDrive
    [[ $DRIVE == "" ]] && {
        warn No SDCard
        return 1
    }

    if [[ $1 == "-s" ]]; then
        du -sh "$DRIVE"/.BACKUPS
        return 0
    fi

    [[ $1 == "-sf" ]] && {
        for file in "$DRIVE"/.BACKUPS/*; do
            echo -ne "$file: "
            du -sh "$file"
            echo
        done
        return 0
    }

    local NUM=0
    local SPACE=" "
    for folder in "$DRIVE"/.BACKUPS/*; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            TMP_folder=${folder//$DRIVE\/.BACKUPS\//}
            backup_info=$(cat "$folder"/.BACKUP.INFO 2>/dev/null)
            [[ $backup_info == "" ]] && backup_info="\e[31mNO_TIME_IMFORMATION\e[32m"
            if [ "$NUM" -gt 9 ]; then
                SPACE=""
            else
                SPACE=" "
            #elif [ $NUM -gt 99 ]; then
            #    SPACE=""
            #else # Not till at least 100
            #    SPACE="  "
            fi
            echo -ne "\e[35m[$NUM]$SPACE\e[32m[$TMP_folder] $backup_info\n"
            NUM=$("$NUM"+1)
        fi
    done
    unset backup_info TMP_folder
}

pack() {
    : ".BACKUPS: pack"
    [[ "$*" == "" ]] && warn No files provided && return 1
    local files
    local DRIVE
    local DATE
    local TAGS=FALSE
    local TAG=""
    local LAP=0

    files=$(read -ar "$@")
    DRIVE=$(GetDrive -o)
    DATE=$(GetDate -o)

    for word in "${files[@]}"; do
        [[ $word == "-t" ]] && TAGS=TRUE && unset -v 'files[$LAP]' && LAP=$((LAP + 1)) && continue
        [[ $TAGS == TRUE ]] && TAG="$TAG$word " && unset -v 'files[$LAP]'
        LAP=$((LAP + 1))
    done

    mkdir "$DRIVE/.BACKUPS/$DATE" || warn Failed to create backup directory "$DRIVE"/"$DATE"
    for file in "${files[@]}"; do
        [[ $file == "" ]] && continue
        [ -d "$file" ] && cp -r "$file" "$DRIVE"/.BACKUPS/"$DATE" && echo Packed "$file" && continue
        [ -f "$file" ] && cp "$file" "$DRIVE"/.BACKUPS/"$DATE" && echo Packed "$file" && continue
        echo "$(yellow)"Failed to move "$file"
    done
    __padRight pack
    [[ $TAG != "" ]] && TAG="\n\e[96m  $TAG"
    echo -ne "\e[33m$(date) \e[90m:: $(cat "$HOME"/.__TEMP_INFO.INFO)$TAG" >"$DRIVE"/.BACKUPS/"$DATE"/.BACKUP.INFO
    rm "$HOME"/.__TEMP_INFO.INFO
}

unback() {
    : ".BACKUPS: unback"
    [[ "$*" == "" ]] && warn No files provided && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        warn Numbers only
        return 1
    fi

    local DRIVE=
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""

    DRIVE=$(GetDrive -o)
    for folder in "$DRIVE"/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq "$1" ] && FOUND=TRUE && FOLDER=$folder && break
            NUM=$((NUM + 1))
        fi
    done

    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        FOLDER_NAME=${FOLDER//$DRIVE\/.BACKUPS\//}
        FOLDER_NAME=${FOLDER_NAME//\//}
    fi
    unset answer
}

cont() {
    : ".BACKUPS: cont"
    # Check if input data is acceptable
    [[ "$*" == "" ]] && backups - && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        warn Numbers only
        return 1
    fi

    local DRIVE
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""

    # Find wanted backup folder
    DRIVE=$(GetDrive -o)
    for folder in "$DRIVE"/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq "$1" ] && FOUND=TRUE && FOLDER=$folder && FOLDER_NAME=${folder//$DRIVE\/.BACKUPS/} && break
            NUM=$((NUM + 1))
        fi
    done

    FOLDER_NAME=${FOLDER_NAME//\//}
    # Main payload
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        local ARGS=$(read -ra "$(find "$FOLDER")")
        local arr=()
        local type=()
        local HEADER="$DRIVE\/.BACKUPS\/$FOLDER_NAME\/"

        # Get content from indevidual files (cat them)
        if [[ $2 != "" ]] && [[ $(echo "$2" | sed 's/i//g') =~ ^[0-9]+$ ]]; then
            local T=0
            for line in "${ARGS[@]}"; do
                [[ $T -eq $(echo "$2" | sed 's/i//g') ]] && [[ -d $line ]] && warn Cannot cat a directory && return 1
                [[ $T -eq $(echo "$2" | sed 's/i//g') ]] && echo -ne "\n$(cat "$line")\n\n" && return 0
                T=$((T + 1))
            done
        fi

        local LAP=0
        # Color coding
        for line in "${ARGS[@]}"; do
            arr["$LAP"]=0
            [ -f "$line" ] && type["$LAP"]="\e[33m"
            [ -d "$line" ] && type["$LAP"]="\e[93m"
            line="${line//$HEADER/}"
            for ((i = 0; i < ${#line}; i++)); do
                local char="${line:$i:1}"
                [[ $char == "/" ]] && arr["$LAP"]=$((arr[LAP] + 1))
            done
            LAP=$((LAP + 1))
        done

        local LAST_LAP=0
        local LAP=0
        local SKIP=TRUE
        # Write out folder content
        echo -ne "\n$FOLDER \n"
        for ((i = 0; i < "${#ARGS[@]}"; i++)); do
            [[ $SKIP == TRUE ]] && SKIP=FALSE && continue
            local line="${ARGS[i]}"
            [[ $line == *".BACKUP.INFO"* ]] && continue
            if [[ $line == "" ]] || [[ $line == " " ]]; then continue; fi
            echo -ne "$(__padLeft $LAP)${type[i]}"
            # Indents
            for ((x = 0; x < 2; x++)); do
                printf '%*s' "${arr[i]}" ""
            done
            printf '%s' "${line//$(RemoveLast "$line")/}"
            [[ $LAP -gt 0 ]] && echo
            [[ $LAST_LAP -gt "${arr[i]}" ]] && [[ "${type[i]}" == "\e[95m" ]] && echo
            LAST_LAP="${arr[i]}"
            LAP=$((LAP + 1))
        done
    fi

    echo
    local FILES=$*
    FILES=${FILES//$1/}
    FILES=(read -ra "$FILES")
    # loop through all sub-directories
    for file in "${FILES[@]}"; do
        [[ $file == "" ]] || cont "$file"
    done
}

goto() {
    : ".BACKUPS: goto"
    [[ "$*" == "" ]] && warn No files provided && return 1
    local DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    for folder in "$DRIVE"/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq "$1" ] && FOUND=TRUE && FOLDER=$folder && break
            NUM=$((NUM + 1))
        fi
    done
    FOLDER_NAME=${FOLDER_NAME//\//}
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        cd "$FOLDER" || warn Failed to change directory to "$FOLDER"
        ls -a
        return 0
    fi
}

overwrite() {
    : ".BACKUPS: overwrite"
    [[ "$*" == "" ]] && warn No files provided && return 1
    [[ "$2" == "" ]] && warn No replacement files provided && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        warn Numbers only
        return 1
    fi
    local DRIVE=
    DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""
    for folder in "$DRIVE"/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq "$1" ] && FOUND=TRUE && FOLDER=$folder && FOLDER_NAME=${folder//$DRIVE\/.BACKUPS/} && break
            NUM=$((NUM + 1))
        fi
    done
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        warn "Are you sure you want to overwrite backup $(magenta)[$1]$(red)? (y/n)"
        while [[ $answer != "y" ]] && [[ $answer != "n" ]]; do
            cat "$FOLDER"/.BACKUP.INFO || warn NO_BACKUP_INFO
            echo -ne "\n$(red)Are you sure you want to remove backup $(magenta)[$1]$(red)? (y/n)\n"
            read -r answer
            [[ $answer != "y" ]] && [[ $answer != "n" ]] && echo -ne "\n$(red)\"y\" or \"n\"\n" && continue
        done
        if [[ $answer == "y" ]]; then
            echo $(green)Removed contents of backup "$FOLDER_NAME"
            local FILES="$*"
            FILES=(read -ra "${FILES//$1 /}")
            FILES=(FILES)
            for file in "${FILES[@]}"; do
                [[ -d $file ]] && cp -r "$file" "$FOLDER"
                [[ -f $file ]] && cp "$file" "$FOLDER"
            done
        fi
        [[ $answer == "n" ]] && warn Aborted && unset answer && return 1
    fi
}

# └ ─ ├
# Need to fix trap "trap"
# It sets trap every time, meaning theres multiple layers of a trapped function
form() {
    : ".BACKUPS: form"
    local A=$*
    [[ $1 == "-a" ]] && {
        asyncform "${A//-a/}"
        return 0
    }
    [[ $2 == "-a" ]] && {
        asyncform "${A//-a/}"
        return 0
    }

    closer() {
        set +f
        unset ARGS

        [[ $1 == "" ]] && echo -ne "\n\n$(red)Exiting\n"

        trap - INT
        return 0
    }

    trap closer INT
    set -f
    IFS='
'
    #local ARGS=($(sudo find . 2>/dev/null))
    [[ $1 == "" ]] && local DIR="."
    mapfile -t ARGS < <(sudo find "$DIR" 2>/dev/null)
    local arr=()
    local type=()
    local HEADER="$(pwd)"
    local LAP=0
    set +f
    unset IFS
    for line in "${ARGS[@]}"; do
        arr["$LAP"]=0
        [ -d "$line" ] && type["$LAP"]="\e[93m"
        [ -f "$line" ] && type["$LAP"]="\e[33m"
        line="${line//$HEADER/}"
        for ((i = 0; i < ${#line}; i++)); do
            local char="${line:$i:1}"
            [[ $char == "/" ]] && arr["$LAP"]=$((arr[LAP] + 1))
        done
        LAP=$((LAP + 1))
    done

    local LAST_LAP=0
    LAP=1
    local LAST_LINE="${#type[@]}"
    local nLEN=${#LAST_LINE}
    LEN=$((nLEN + 2))
    local SKIP=TRUE

    for ((i = 0; i < "${#ARGS[@]}"; i++)); do
        [[ $SKIP == TRUE ]] && SKIP=FALSE && continue
        local line="${ARGS[i]}"
        [[ $line == *".BACKUP.INFO"* ]] && continue
        [[ $line == "" ]] && continue
        echo -ne "$(__padLeft $LAP $LEN)${type[i]}"
        for ((x = 0; x < 2; x++)); do
            printf '%*s' "${arr[i]}" ""
        done
        #echo -ne $i : $line
        echo -ne "${line//$(RemoveLast "$line")/}"
        [[ $LAP -gt 0 ]] && echo
        [[ $LAST_LAP -gt "${arr[i]}" ]] && [[ "${type[i]}" == "\e[95m" ]] && echo
        LAST_LAP="${arr[i]}"
        LAP=$((LAP + 1))
    done

    closer
}

# Not fully working
asyncform() {
    echo "$*"
    : ".BACKUPS: asyncform"
    local DIR=${1:-.}               # use the first argument as the directory, or '.' if not provided
    [[ "$DIR" == "/" ]] && DIR=
    local HEADER=$(realpath "$DIR") # get the absolute path of the directory
    local LAP=0                     # line number
    local arr=()                    # array to store the number of levels deep each file is
    local type=()                   # array to store the color code for each file
    local SKIP=TRUE                 # flag to skip the first line
    local LAST_LAP=0                # last level
    local LAST_TYPE=none            # last file type

    # recursive function to process files and directories
    function process_file() {
        local file=$1
        local level=$2
        arr["$LAP"]=$level

        # determine the color code based on the type of file
        if [[ -d "$file" ]]; then
            type["$LAP"]="\e[93m" # yellow for directories
        else
            type["$LAP"]="\e[33m" # orange for files
        fi

        # print the line
        echo -ne "$(__padLeft $LAP $LEN)${type[$LAP]}" # Right after file intext ([INT]HERE)
        for ((i = 0; i < 2; i++)); do
            printf '%*s' "$level" "" # The spacing between the index and file name
        done
        local t="${file//$(RemoveLast "$file")/}" #"${file//$HEADER/}" # The actual filename
        echo -ne "${t:1}\n"

        LAST_LAP=$LAP
        LAST_TYPE=${type[$LAP]}
        LAP=$((LAP + 1))

        # if it's a directory, process its contents recursively
        if [[ -d "$file" ]]; then
            local subfiles=("$file"/*)
            for subfile in "${subfiles[@]}"; do
                process_file "$subfile" $((level + 1))
            done
        fi
    }

    # calculate the length of the longest line number, to pad the output
    local LAST_LINE="${#type[@]}"
    LAST_LINE=${#LAST_LINE}
    LEN=$("$LAST_LINE"+4)

    # loop over all files and directories in the given directory
    //find "$DIR" -mindepth 1 -maxdepth 1 ! -name '.BACKUP.INFO' -exec "$BACKS"/.PROCESS_FILE.sh bash {} +
    for file in "$DIR"/* "$DIR"/.[!.]*; do
        [[ "$file" == */.BACKUP.INFO ]] && continue

        [[ $SKIP == TRUE ]] && {
            SKIP=FALSE
            continue
        }
        process_file "$file" 0
    done
}

count_lines() {
    : ".BACKUPS: count_lines"
    # Check if the directory path is provided
    if [[ -z "$1" ]]; then
        warn "Directory path is missing."
        return 1
    fi

    local directory="$1"
    local total_lines=0

    # Iterate through each file in the directory
    for file in "$directory"/*; do
        # Check if the file is a regular file (not a directory)
        if [[ -f "$file" ]]; then
            # Count the number of lines in the file and add it to the total line count
            local file_lines=$(wc -l <"$file")
            total_lines=$((total_lines + file_lines))
        fi
    done

    # Print the total number of lines
    echo "$total_lines"
}
