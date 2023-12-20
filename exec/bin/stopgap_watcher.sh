#!/usr/bin/env bash
## stopgap_watcher.sh
# A wrapper script for running stopgap_watcher.
#
# WW 06-2019


set -e              # Crash on error
set -o nounset      # Crash on unset variables

# Parse input arguments
args=("$@")
rootdir=${args[0]}
paramfilename=${args[1]}
n_cores=${args[2]}
run_type=${args[3]}
submit_cmd=${args[4]}


# Check for local
if [ "${run_type}" = "local" ]; then
    source $STOPGAPHOME/lib/stopgap_config_franklin.sh 
elif [ "${run_type}" = "slurm" ]; then
    source $STOPGAPHOME/lib/stopgap_config_accre2.sh 
else
    echo 'ACHTUNG!!! Invalid run_type!!!'
    echo 'Only supported run_types are "local", and "slurm"!!!'
    exit 1
fi



# Set MCR directory
source $STOPGAPHOME/lib/stopgap_prepare_mcr.sh 

# Run matlab script
eval $STOPGAPHOME/lib/stopgap_watcher ${rootdir} ${paramfilename} ${n_cores} "'${submit_cmd}'"
# echo ${rootdir} ${paramfilename} ${n_cores} "'${submit_cmd}'"
# echo "$@"

# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_watcher



