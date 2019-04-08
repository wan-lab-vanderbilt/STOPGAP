#!/usr/bin/env bash
## stopgap_kontrolleur.sh
# A wrapper script for running stopgap_kontrolleur.
#
# WW 05-2018

# Bash parameters
source $STOPGAPHOME/lib/stopgap_config.sh 

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/subtomo_kontrolleur" ]; then
    rm -rf /tmp/${USER}/mcr/subtomo_kontrolleur
fi
mkdir -p /tmp/${USER}/mcr/subtomo_kontrolleur
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/subtomo_extract"


# Run matlab script
$STOPGAPHOME/lib/stopgap_kontrolleur "$@"

# Cleanup
rm -rf /tmp/${USER}/mcr/subtomo_kontrolleur
