#!/bin/bash

core::error() {
    : "bashext: error"
    printf '%s%s%s%s\n' "$(trace '' '' ': ' 2>/dev/null)" "$RED" "$*" "$NORM" >&2
}

core::warn() {
    : "bashext: warn"
    printf '%s%s%s%s\n' "$(trace '' '' ': ' 2>/dev/null)" "$YELLOW" "$*" "$NORM" >&2
}
