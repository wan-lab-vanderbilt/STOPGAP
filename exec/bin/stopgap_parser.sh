#!/usr/bin/env bash
## stopgap_parser.sh
# A wrapper script for running stopgap_parser.
#
# WW 06-2018

# Bash parameters
source $STOPGAPHOME/lib/stopgap_config.sh 

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/subtomo_parser" ]; then
    rm -rf /tmp/${USER}/mcr/subtomo_parser
fi
mkdir -p /tmp/${USER}/mcr/subtomo_parser

# Run parser
$STOPGAPHOME/lib/stopgap_parser "$@"

# Cleanup MCR
rm -rf /tmp/${USER}/mcr/subtomo_parser
