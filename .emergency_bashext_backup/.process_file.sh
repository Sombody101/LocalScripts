#!/bin/bash

# What the fuck even is this?
exit

#using $BACKS/.BACKUP.sh

file=$1
level=$2
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
t="${file//$(RemoveLast "$file")/}" #"${file//$HEADER/}" # The actual filename
echo -ne "${t:1}\n"

LAST_LAP=$LAP
LAST_TYPE=${type[$LAP]}
LAP=$((LAP + 1))

# if it's a directory, process its contents recursively
if [[ -d "$file" ]]; then
    subfiles=("$file"/*)
    for subfile in "${subfiles[@]}"; do
        process_file "$subfile" $((level + 1))
    done
fi
