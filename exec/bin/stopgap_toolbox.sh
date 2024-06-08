#!/usr/bin/env bash
## stopgap_toolbox.sh
# A wrapper script for running the standalone stopgap toolbox.
#
# WW 05-2024

# Bash parameters
source $STOPGAPHOME/lib/stopgap_config.sh 

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/subtomo_parser" ]; then
    rm -rf /tmp/${USER}/mcr/sg_toolbox
fi
mkdir -p /tmp/${USER}/mcr/sg_toolbox

# Run parser
$STOPGAPHOME/lib/sg_toolbox "$@"

# Cleanup MCR
rm -rf /tmp/${USER}/mcr/sg_toolbox
