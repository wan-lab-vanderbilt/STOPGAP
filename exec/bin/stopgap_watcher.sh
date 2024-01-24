#!/usr/bin/env bash
## stopgap_watcher.sh
# A wrapper script for running stopgap_watcher.
#
# WW 01-2024

set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Set root of local temporary folder
LOCAL_TEMP_ROOT=/tmp/


# Parse input arguments
args=("$@")
rootdir=${args[0]}
paramfilename=${args[1]}
n_cores=${args[2]}
run_type=${args[3]}
submit_cmd=${args[4]}


# Check for local
if [ "${run_type}" = "local" ]; then
    source $STOPGAPHOME/lib/stopgap_config_local.sh 
elif [ "${run_type}" = "slurm" ]; then
    source $STOPGAPHOME/lib/stopgap_config_slurm.sh 
else
    echo 'ACHTUNG!!! Invalid run_type!!!'
    echo 'Only supported run_types are "local", and "slurm"!!!'
    exit 1
fi



# Set MCR directory
source $STOPGAPHOME/lib/stopgap_prepare_mcr.sh ${LOCAL_TEMP_ROOT}

# Run matlab script
eval $STOPGAPHOME/lib/stopgap_watcher ${rootdir} ${paramfilename} ${n_cores} "'${submit_cmd}'"


# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_watcher



