#!/usr/bin/env bash
## stopgap_extract_subtomograms_mpi.sh
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
tomo_folder=${args[1]}
tomo_digits=${args[2]}
tomo_row=${args[3]}
subtomoname=${args[4]}
subtomo_digits=${args[5]}
allmotlfilename=${args[6]}
subtomosize=${args[7]}
statsname=${args[8]}
checkjobdir=${args[9]}

# Get OPENMPI environmental parameters
procnum=$OMPI_COMM_WORLD_RANK       # Get rank number
procnum=$((procnum+1))              # Start rank number at 1

# Set MCR directory
if [ -d "/tmp/${USER}/mcr/subtomo_extract_${procnum}" ]; then
    rm -rf /tmp/${USER}/mcr/subtomo_extract_${procnum}
fi
mkdir -p /tmp/${USER}/mcr/subtomo_extract_${procnum}
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/subtomo_extract_${procnum}"


# Run matlab script
$STOPGAPHOME/lib/stopgap_extract_subtomograms $tomo_folder $tomo_digits $tomo_row $subtomoname $subtomo_digits $allmotlfilename $subtomosize $statsname $checkjobdir $procnum 

# Cleanup
rm -rf ./mcr/subtomo_extract_${procnum}




