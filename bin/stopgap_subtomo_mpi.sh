#!/usr/bin/env bash
## stopgap_subtomo_mpi.sh
# A script for running stopgap_subtomo and obtaining MPI variables.
#
# WW 01-2018

# Bash parameters
source $STOPGAPHOME/lib/stopgap_config.sh 

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Parse input arguments
args=("$@")
rootdir=${args[0]}
paramfilename=${args[1]}

# Get OPENMPI environmental parameters
procnum=$OMPI_COMM_WORLD_RANK       # Get rank number
procnum=$((procnum+1))              # Start rank number at one

# Go to root directory
cd $rootdir

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/stopgap_subtomo_${procnum}" ]; then
    rm -rf /tmp/${USER}/mcr/stopgap_subtomo_${procnum}
fi
mkdir -p /tmp/${USER}/mcr/stopgap_subtomo_${procnum}
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/stopgap_subtomo_${procnum}"

# Run matlab script
$STOPGAPHOME/lib/stopgap_subtomo ${rootdir} ${paramfilename} ${procnum}

# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_subtomo_${procnum}

