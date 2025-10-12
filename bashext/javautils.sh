#!/bin/bash

flag WSL || return 0

# JAVA_BIN="/mnc/c/Program Files/Java/jdk-23/bin/java.exe"
# APKOGNITO_TOOLS_WIN='C:\\Users\\'$USER's\\AppData\\Roaming\\APKognito\\tools'
APKOGNITO_TOOLS="/mnt/c/Users/${USER}s/AppData/Roaming/APKognito/tools"

apk.unpack() {
    [[ ! "$1" ]] && {
        core::error "No file given."
        return 1
    }

    local outputDirectory="${2:-./}"
    java -jar "$APKOGNITO_TOOLS/apktool.jar" d "$1" -o "${outputDirectory}/unpack_$1"
}

apk.pack() {
    :
}

apk.sign() {
    :
}

register_module apk