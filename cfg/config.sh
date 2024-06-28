#!/bin/bash

### Configs ###

#
# FORCE_BACKUP: Force the script to load a backup, even if the USB BashExt is available
#
: FORCE_BACKUP=true

#
# FORCE_PATH: Force the script to load from a specific path rather than the default
#
: FORCE_PATH="$HOME/LocalScripts"

#
# FORCE_COLOR: Force the color variables to be set even in a terminal that doesn't support color (No effect on color functions)
#
: FORCE_COLOR="TRUE"

### End Configs ###

___full_backup_path="$FORCE_PATH"

# Give configuration (when using set -x)
: "Current configuration:"
: "  $___full_backup_path"
: "  $FORCE_BACKUP"

alias lscnfg='ed $HOME/LocalScripts/cfg/config.sh'