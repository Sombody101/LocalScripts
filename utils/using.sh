#!/bin/bash

using() {
    : ".loader.bashrc: using"
    : "<file path> <option>"
    : "-f: Hide errors"
    : "-o: Verbose info"

    local file="$1"

    # Check if arg is not an absolute path
    if [[ "$file" != "/"* ]]; then
        local scripts=("$__using_path/$file"*)
        local s_len="${#scripts[@]}"

        if [[ "$s_len" -gt 1 ]]; then

            # More than one script found with this name (or prefix)

            warn "Found multiple scripts starting with '$file':"
            for item in "${scripts[@]}"; do
                printf '\t%s\n' "$item"
            done

            add_managed_import 2 "$(_indigo)atmp_path:$NORM $file"
            return 1
        fi

        file="${scripts[0]}"
    fi

    if [[ ! -f "$file" ]]; then
        [[ "$2" != '-f' ]] && {
            warn "Unable to find '$file'"
            add_managed_import 1 "$(_indigo)atmp_path:$NORM $file"
            return 1
        }

        add_managed_import 1 "${MAGENTA}soft_path:$NORM $file"
        return 1
    fi

    add_managed_import 0 "${CYAN}full_path:$NORM $(realpath "$file")"

    if ! source "$file"; then
        add_managed_import "$RED" "ERROR" "${RED}full_path:$NORM $(realpath "$file")"
    fi

    if [[ "$2" == '-o' ]]; then
        echo "$BLUE'$file' found [$1]$NORM"
        return 0
    fi
}
