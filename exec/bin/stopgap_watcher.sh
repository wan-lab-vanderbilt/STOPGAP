#!/usr/bin/env bash
## stopgap_watcher.sh
# A wrapper script for running stopgap_watcher.
#
# WW 06-2019

# Bash parameters
source $STOPGAPHOME/lib/stopgap_config.sh 

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/stopgap_watcher" ]; then
    rm -rf /tmp/${USER}/mcr/stopgap_watcher
fi
mkdir -p /tmp/${USER}/mcr/stopgap_watcher
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/stopgap_watcher"


# Run matlab script
$STOPGAPHOME/lib/stopgap_watcher "$@"

# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_watcher
