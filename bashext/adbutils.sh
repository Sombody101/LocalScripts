#!/bin/bash

adb::pull_multi_app() {
    [[ ! "$1" ]] && {
        core::error "No package path given."
        return
    }

    which adb >/dev/null || {
        core::error "ADB isn't on PATH."
        return
    }

    local dir="$1"
    [[ "$dir" == *"base.apk" ]] && {
        dir="$(dirname "$1")"
    }

    adb shell "find $dir -name *.apk 2>/dev/null" | while IFS=$'\r\n' read -r file; do
        file=$(echo "$file" | tr -d '\r')
        xxd <<< $file

        [[ ! "$file" ]] && continue

        echo "Pulling $(basename "$file")"
        adb pull "$file"
    done
}

register_module adb
