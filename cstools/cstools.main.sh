#!/bin/bash

# This file contains C# Compilation tools to assist in application creation (DotNet general)
# Any binary executables should be placed in $DRIVE/.BACKUPS/.LOADER/bin

# CST = this # Defined in parent script

# Functions provided
# dncheck : Checks for any DotNet Core SDK installations
# dnrun   : The same as running "sudo dotnet run", but faster (Using "sudo" helps with file permissions)
# dnbuild : The same as running "sudo dotnet build" (Same addons as 'dnrun')

# Register file
regload "$CST_M"

# Error codes
dne=(
    "No DotNet SDK"
    "No project in current directory"
    ""
    "Invalid/Unknown input switch"
)

# Faster access
dne1="${dne[1]}"
dne2="${dne[2]}"
dne3="${dne[3]}"
dne4="${dne[4]}"

DN_CS_C="$CST"/dn-cstools-core.sh # Dotnet-Core tools
DN_CS_FW="$CST"/dn-cstools-fw.sh  # Dotnet-Framework tools

using "$DN_CS_C"
using "$DN_CS_FW"

dncheck() {
    [[ ! "$*" =~ -f ]] && [[ "$SDK" != "" ]] && return 0
    ! dotnet --version >"$NULL" && {
        warn "No DotNet installation found"
        SDK="$dne1"
        return 1
    }

    local out=
    out="$(dotnet --version)"
    SDK="$out"

    # This is where arguments would apply (They have no effect when there's no SDK)
    [[ "$1" == "-o" ]] && echo "$out"
    return 0
}

SDK='UNSET | USE dncheck' # $(dncheck -o || echo "$dne1")
alias SDK='echo "$SDK"' # Also helps with syntax warning

dnrun() {
    dncheck NULL || return 1 # Use a random input once to keep syntax highlighter chill
    sudo dotnet run $*
}

dnbuild() {
    dncheck || return 1
    sudo dotnet build $*
}

# Helper functions
dn_sep_str() {
    IFS=':' read -ra parts <<<"$1"
    echo "${parts[@]}"
}
