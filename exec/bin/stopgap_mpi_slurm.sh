#!/usr/bin/env bash
## stopgap_mpi_slurm.sh
# A script for running stopgap_subtomo and obtaining the 
# proper parallelization variables. This is either when
# using mpirun or srun with slurm.
#
# WW 04-2019

# Source libraries
source $STOPGAPHOME/lib/stopgap_config.sh 

# Bash parameters
set -e              # Crash on error
set -o nounset      # Crash on unset variables


# Parse input arguments
args=("$@")
rootdir=${args[0]}
paramfilename=${args[1]}
n_cores=${args[2]}


# Get environmental parameters
mpi_test=${OMPI_COMM_WORLD_RANK:-}
slurm_test=${SLURM_PROCID:-}
if [[ ${mpi_test} ]]; then
    # For mpirun
    procnum=$OMPI_COMM_WORLD_RANK       # Get rank number
    node_name=$HOSTNAME
    run_type=MPI
elif [[ ${slurm_test} ]]; then
    # For slurm
    procnum=$SLURM_PROCID       # Get rank number
    node_name=$SLURMD_NODENAME
    run_type=SLURM
else
    echo "ACHTUNG!!! Could not obtain rank from Slurm or MPI variables!!!"
    exit 1
fi
# Set process number
procnum=$((procnum+1))              # Start rank number at one
echo "Running using ${run_type}... procnum: $procnum - hostname: $node_name"

# Go to root directory
cd $rootdir


# Set MCR directory
if [ -d "/tmp/${USER}/mcr/stopgap_${procnum}" ]; then
    rm -rf /tmp/${USER}/mcr/stopgap_${procnum}
fi
mkdir -p /tmp/${USER}/mcr/stopgap_${procnum}
export MCR_CACHE_ROOT="/tmp/${USER}/mcr/stopgap_${procnum}"


# Run matlab script
# /usr/bin/time -v 
$STOPGAPHOME/lib/stopgap ${rootdir} ${paramfilename} ${procnum} ${n_cores}


# Cleanup
rm -rf /tmp/${USER}/mcr/stopgap_${procnum}
