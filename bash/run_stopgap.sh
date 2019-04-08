#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## run_stopgap.sh
# A script for performing subtomogram averaging using the 'stopgap' 
# impelemtnation of the TOM/AV3 package on a SGE cluster. This script first
# generates a submission file and then launches 'stopgap_watcher', a MATLAB
# executable that manages the flow of stopgap averging jobs on the cluster.
#
# Stopgap uses a special .star file to define the subtomogram averaging 
# parameters. These .star files can be generated using 'stopgap_job_parser.sh'.
#
# WW 11-2017

##### RUN LOCAL #####
run_local=false              # Set to true to run locally. This supercedes running on the cluster.
local_cores=20               # Number of local cores to use.

##### SGE OPTIONS #####
total_cores=96             # Number of subtomogram alignment cores
queue='p.192g'              # Queue for alignment jobs
mem_limit='5G'              # Amount of memory per node (G = gigabytes)
wall_time=604800            # Maximum run time (604800 seconds)

##### DIRECTORIES #####
rootdir='/path/to/averaging/folder/'    # Main subtomogram averaging directory
paramfilename='param.star'          # Relative path to stopgap parameter file. 





################################################################################################################################################################
##### SUBTOMOGRAM AVERAGING WORKFLOW                                                                                                       ie. the nasty bits...
################################################################################################################################################################

# Path to MATLAB executables
stopgap_path=""
kontrolleur="${stopgap_path}stopgap_kontrolleur.sh"
stopgap_subtomo="${stopgap_path}stopgap_subtomo_mpi.sh"

# Remove previous submission script
rm -f submit_stopgap

if [ "${run_local}" = true ]; then
    echo "Running stopgap locally..."
    
    # Reset number of cores
    total_cores=$local_cores

    # Local submit command
    submit_cmd="mpiexec -np ${total_cores} ${stopgap_subtomo} ${rootdir} ${paramfilename}  2> ${rootdir}/error_stopgap 1> ${rootdir}/log_stopgap &"
    # echo ${submit_cmd}
else
    echo "Preparing to run stopgap on cluster..."

    # Write submission script
    echo "#!/bin/bash" > submit_stopgap
    echo "#$ -pe openmpi ${total_cores}" >> submit_stopgap             # Number of cores
    echo "#$ -l h_vmem=${mem_limit}" >> submit_stopgap                 # Memory limit
    echo "#$ -l h_rt=${wall_time}" >> submit_stopgap                   # Wall time
    echo "#$ -q ${queue}" >> submit_stopgap                            # Averaging queue
    echo "#$ -S /bin/bash" >> submit_stopgap                           # Submission environment
    echo "source ~/.bashrc" >> submit_stopgap                          # Get proper envionment; i.e. modules
    echo "mpiexec -np ${total_cores} ${stopgap_subtomo} ${rootdir} ${paramfilename} 2> >(sed 's/^/${HOSTNAME}: /' >> ${rootdir}/error_stopgap) 1> >(sed 's/^/${HOSTNAME}: /' >> ${rootdir}/log_stopgap)" >> submit_stopgap
    echo "exit" >> submit_stopgap
    
    # Make executable
    chmod +x submit_stopgap
    
    # Submission command
    submit_cmd="qsub submit_stopgap"
fi



# Run watcher
eval "${kontrolleur} ${rootdir} ${paramfilename} ${total_cores} '${submit_cmd}'"
rm -f submit_stopgap

exit





