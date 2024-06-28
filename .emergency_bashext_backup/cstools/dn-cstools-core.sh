#!/bin/bash

# This file contains C# Compilation tools to assist in application creation (DotNet-Core specific)
# Any binary executables should be placed in $DRIVE/.BACKUPS/.LOADER/bin

# DN_CS_C = $CST/dn-cdtools-core.sh # Defined in parent script

# Functions provided
# dnpublish  :
#

dnpublish() {
    dncheck || return 1

    local inProj="FALSE"
    for file in *; do
        [[ "$file" == *".csproj" ]] && inProj="TRUE"
    done

    [[ "$inProj" == "FALSE" ]] && {
        warn "$dne3"
        return 3
    }

    local compilingFor=

    for arg in "$@"; do
        [[ "$arg" == "-"* ]] && {
            # Parse single letter switches
            for ((i = 0; i < ${#arg}; i++)); do
                local l="${arg:i:1}"
                case "$l" in
                "-") ;; # Just ingore slashes
                *)
                    warn "$dne4 -$l" # Unknown switch
                    return 4
                    ;;
                esac
            done
        } || {
            # Parse whole word switches
            case "$arg" in
            *win)
                read -ra strs <<<"$(dn_sep_str "$arg")"

            ;;
            *)
                warn "$dne4 -$arg"
                return 4
                ;;
            esac
        }
    done

    # Start project compilation

}
