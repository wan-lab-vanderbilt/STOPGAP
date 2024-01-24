#!/usr/bin/env bash
## stopgap_mpi_slurm.sh
# A script for running stopgap_subtomo and obtaining the 
# proper parallelization variables. This is either when
# using mpirun or srun with slurm.
#
# WW 01-2024


# Bash parameters
set -o nounset      # Crash on unset variables

# Load MATLAB module
module load MATLAB/2020b    # Remove or update as necessary

# Set root of local temporary folder
LOCAL_TEMP_ROOT=/tmp/

# Parse input arguments
args=("$@")
rootdir=${args[0]}
paramfilename=${args[1]}
n_cores=${args[2]}
copy_local=${args[3]}
run_type=${args[4]}


# Source libraries. There are two config files in case your local and SLURM configurations have different methods for sourcing libraries. 
if [ "${run_type}" = "local" ]; then
    echo "Sourcing libraries for local run..."
    source $STOPGAPHOME/lib/stopgap_config_local.sh 

elif [ "${run_type}" = "slurm" ]; then
    echo "Sourcing libraries for SLURM run..."
    source $STOPGAPHOME/lib/stopgap_config_slurm.sh 

fi


# Get environmental parameters
mpi_test=${OMPI_COMM_WORLD_RANK:-}
slurm_test=${SLURM_PROCID:-}
if [[ ${mpi_test} ]]; then
    # For mpirun
    procnum=$OMPI_COMM_WORLD_RANK       # Get rank number
    local_id=$OMPI_COMM_WORLD_RANK
    node_name=$HOSTNAME
    run_type="MPI"

elif [[ ${slurm_test} ]]; then
    # For slurm
    procnum=$SLURM_PROCID       # Get rank number
    node_name=$SLURMD_NODENAME  # Name of node
    job_id=${SLURM_JOB_ID}       # Job ID
    node_id=${SLURM_NODEID}     # Node ID
    n_nodes=${SLURM_NNODES}     # Number of nodes
    local_id=${SLURM_LOCALID}   # Local core ID on node
    cpus_on_node=${SLURM_CPUS_ON_NODE}  # CPUs assigned to current node
    run_type="SLURM"
    node_id=$((node_id+1))              # Start node ID at one

else
    echo "ACHTUNG!!! Could not obtain rank from Slurm or MPI variables!!!"
    exit 1
fi
# Set ID numbers to start at 1
procnum=$((procnum+1))              # Start rank number at one
local_id=$((local_id+1))            # Start local ID at one


# Go to root directory
cd $rootdir


# Set MCR directory
source $STOPGAPHOME/lib/stopgap_prepare_mcr.sh ${LOCAL_TEMP_ROOT}

# Set local temporary directory
if [ $copy_local -gt 0 ]; then

    export LOCAL_TEMP="$LOCAL_TEMP_ROOT/stopgap_u${UID}/" 

    if [ $local_id = 1 ]; then
        
        if [ $copy_local = 1 ]; then
            echo "Using local temporary storage..."
            source $STOPGAPHOME/lib/stopgap_prepare_local_temp.sh $LOCAL_TEMP
        elif [ $copy_local -ge 2 ]; then
            echo "Using persistent local storage..."                                 
            mkdir $LOCAL_TEMP
        fi

    else
        echo "Using temporary local storage..."
    fi
fi

# Run STOPGAP
if [ $run_type = "MPI" ]; then
    echo "Running using ${run_type}... procnum: $procnum - hostname: $node_name"

        $STOPGAPHOME/lib/stopgap rootdir ${rootdir} paramfilename ${paramfilename} procnum ${procnum} n_cores ${n_cores} user_id ${UID} node_name ${node_name} n_nodes 1 local_id ${procnum} copy_local ${copy_local}

elif [ $run_type = "SLURM" ]; then
    echo "Running using ${run_type}... procnum: $procnum - hostname: $node_name - node_id: $SLURM_NODEID local_id: $SLURM_LOCALID - CPUs on Node: $SLURM_CPUS_ON_NODE"    
    $STOPGAPHOME/lib/stopgap rootdir ${rootdir} paramfilename ${paramfilename} procnum ${procnum} n_cores ${n_cores} user_id ${UID} job_id ${job_id} node_name ${node_name} node_id ${node_id} n_nodes ${n_nodes} cpus_on_node ${cpus_on_node} local_id ${local_id} copy_local ${copy_local}

fi


# Check for crash
err=$?
if [ 0 -ne $err ]; then
    
    # Crash file name
    crash_name="${rootdir}/crash_${procnum}"

	# Write crash file
	if [ $run_type = "MPI" ]; then
        echo "ACHTUNG!!!1! ${run_type} job crashed with code ${err} for procnum: $procnum - hostname: $node_name" | tee $crash_name >(cat >&2)

    elif [ $run_type = "SLURM" ]; then
        echo "ACHTUNG!!!1! ${run_type} job crashed with code ${err}  for procnum: $procnum - hostname: $node_name - node_id: $SLURM_NODEID local_id: $SLURM_LOCALID" | tee $crash_name >(cat >&2)
    fi

    exit ${err}
fi




