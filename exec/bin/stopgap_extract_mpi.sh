#!/usr/bin/env bash
## stopgap_extract_mpi.sh
# A script for running stopgap_extract and obtaining MPI variables.
#
# WW 01-2018

# Bash parameters
set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Source libraries
source $STOPGAPHOME/lib/stopgap_config.sh 

# Parse input arguments
args=("$@")
rootdir=${args[0]}
param_name=${args[1]}

# Get OPENMPI environmental parameters
procnum=$OMPI_COMM_WORLD_RANK       # Get rank number
procnum=$((procnum+1))              # Start rank number at one

# Go to root directory
cd $rootdir

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/stopgap_extract_${procnum}" ]; then
    rm -rf /tmp/${USER}/mcr/stopgap_extract_${procnum}
fi
mkdir -p /tmp/${USER}/mcr/stopgap_extract_${procnum}
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/stopgap_extract_${procnum}"

# Run matlab script
$STOPGAPHOME/lib/stopgap_extract ${rootdir} ${param_name} ${procnum}

# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_extract_${procnum}
