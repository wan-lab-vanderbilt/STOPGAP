#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## run_stopgap.sh
# A script for performing subtomogram averaging using 'stopgap'.
# This script first generates a submission file and then launches 
# 'stopgap_watcher', a MATLAB executable that manages the flow of parallel 
# stopgap averging jobs.
#
# WW 01-2024


##### RUN OPTIONS #####
run_type='slurm'            # Types supported are 'local' and 'slurm', for local and slurm-cluster submissions.
nodes=1                     # Number of nodes to reserve. Set to 0 if not reserving full nodes.
n_cores=32                  # Number of subtomogram alignment cores; if reserving nodes, should be in multiples of cores/node.
queue='production'          # SLURM queue. Ignored for local jobs.
mem_limit='7G'              # Amount of memory per node (G = gigabytes). Ignored for local jobs.
wall_time='03-00:00:00'     # Maximum run time in seconds (format: [dd-hh:mm:ss]). Ignored for local jobs.
job_name='stopgap'          # SLURM job name. Ignored for local jobs.
account='account'           # SLURM account to charge. Ignored for local jobs.
copy_local=1                # Copy processing data to local temporary storage. 0 = off, 1 = temporary, 2 = persistent. 
reservation='none'          # SLURM reservation. Set to 'none' for no reservation. Ignored for local jobs.

##### DIRECTORIES #####
rootdir='rootdir'                               # Main subtomogram averaging directory
paramfilename='params/subtomo_param.star'       # Relative path to stopgap parameter file. 



################################################################################################################################################################
##### SUBTOMOGRAM AVERAGING WORKFLOW                                                                                                       ie. the nasty bits...
################################################################################################################################################################


# Path to MATLAB executables
watcher="${STOPGAPHOME}/bin/stopgap_watcher.sh"
subtomo="${STOPGAPHOME}/bin/stopgap_mpi_slurm.sh"


# Remove previous submission script
rm -f submit_stopgap

if [ "${run_type}" = "local" ]; then
    echo "Running stopgap locally..."


    # Local submit command
    submit_cmd="mpiexec -np ${n_cores} ${subtomo} ${rootdir} ${paramfilename} ${n_cores} ${copy_local} ${run_type} 2> ${rootdir}/error_stopgap 1> ${rootdir}/log_stopgap &"




elif [ "${run_type}" = "slurm" ]; then
    # Default SLURM parameters
    cpus_per_task=1             # CPUs per task; for STOPGAP this should always be 1
        
    echo "Preparing to run stopgap on slurm-cluster..."


    # Write submission script
    echo "#!/bin/bash" > submit_stopgap                                                # Use BASH environment
    echo "#SBATCH -D ${rootdir}" >> submit_stopgap                                              # Set working directory
    echo "#SBATCH -e error_stopgap" >> submit_stopgap                                           # Output error file
    echo "#SBATCH -o log_stopgap" >> submit_stopgap                                             # Output log file
    echo "#SBATCH -J ${job_name}" >> submit_stopgap                                             # Job name
    echo "#SBATCH --partition=${queue} " >> submit_stopgap                                      # Partition name
    if [ $nodes -ne 0 ]; then    
        echo "#SBATCH --nodes=${nodes} " >> submit_stopgap                                      # Number of nodes
    fi
    echo "#SBATCH --ntasks=${n_cores}" >> submit_stopgap                                        # Number of tasks; i.e. CPUs
    echo "#SBATCH --cpus-per-task=${cpus_per_task}" >> submit_stopgap                           # CPUs per task, should generally be 1
    echo "#SBATCH --mem-per-cpu=${mem_limit}" >> submit_stopgap                                 # Memory per CPU
    echo "#SBATCH --time=${wall_time}" >> submit_stopgap                                        # Max wall time
    echo "#SBATCH --account=${account}" >> submit_stopgap                                       # Account to charge
    if [ "${reservation}" != "none" ]; then
        echo "#SBATCH --reservation=${reservation}" >> submit_stopgap                               # SLURM Reservation
    fi
    echo "srun ${subtomo} ${rootdir} ${paramfilename} ${n_cores} ${copy_local} ${run_type}" >> submit_stopgap

    # Make executable
    chmod +x submit_stopgap
    
    # Submission command
    submit_cmd="sbatch submit_stopgap"

else
    echo 'ACHTUNG!!! Invalid run_type!!!'
    echo 'Only supported run_types are "local", and "slurm"!!!'
    exit 1
fi



# Run watcher
eval "${watcher} ${rootdir} ${paramfilename} ${n_cores} ${run_type} '${submit_cmd}'"
rm -f submit_stopgap

exit




