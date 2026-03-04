#!/bin/bash

# Color creator

readonly COLOR_SHEET="$LS/.bcolorsheet.sh"
using "$COLOR_SHEET" -f

colors.make() {
    : "colors.make: Create RGB color variables."
    : "<color code> <color name>"
    : "colors.make 255:255:255 white"
    : "colors.make '255;255;255' white"

    local format name

    [[ ! "$*" ]] && {
        core::error "No arguments given."
        return
    }

    format="$1"
    name="$2"

    [[ ! "$name" ]] && {
        core::error "No color name given."
        return
    }

    [ -v "$name" ] && {
        core::error "The variable '$name' is already defined."
        return
    }

    # Replace ':' with ';' as shorthand
    printf '%s="\x1b[38;2;%sm"\n' "$name" "${format//:/\;}" >>"$COLOR_SHEET"

    # Use source here so the path isn't added to mimports again.
    # shellcheck source=/dev/null
    source "$COLOR_SHEET"

    echo "${!name}$name$NORM"
}

colors.remove() {
    local target="$1"

    if sed -i "/^$target=/d" "$COLOR_SHEET"; then
        echo "Removed color '$target'"
        unset "$target"
        return
    fi

    core::error "Failed to find '$target'" >&2
    return
}

colors.list() {
    [ ! -f "$COLOR_SHEET" ] && {
        core::error "No color sheet"
        return
    }

    local prefix
    while IFS= read -r line; do
        prefix=(${line/=/ })
        echo "${!prefix[0]}${prefix[0]}$NORM"
    done <"$COLOR_SHEET"
}

register_module colors
