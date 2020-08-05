#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## run_stopgap.sh
# A script for performing subtomogram averaging using 'stopgap'.
# This script first generates a submission file and then launches 
# 'stopgap_watcher', a MATLAB executable that manages the flow of parallel 
# stopgap averging jobs.
#
# Stopgap uses a special .star file to define the subtomogram averaging 
# parameters. These .star files can be generated using 'stopgap_job_parser.sh'.
#
# WW 06-2018

### MPI Biochem specifics ###
# hpcl4001 queues: p.192g p.512g - 40 cores/node
# hpcl7001 queues: p.512g - 32 cores/node
# hpcl8001 queues: p.hpcl8 - 24 cores/node


##### RUN OPTIONS #####
run_type='slurm'            # Types supported are 'local', 'sge', and 'slurm', for local, SGE-cluster and slurm-cluster submissions.
n_cores=96                 # Number of subtomogram alignment cores
queue='p.hpcl8'              # Queue for alignment jobs. Ignored for local jobs.
mem_limit='8G'             # Amount of memory per node (G = gigabytes). Ignored for local jobs.
wall_time=604800            # Maximum run time in seconds (max = 604800 seconds). Ignored for local jobs.

##### DIRECTORIES #####
rootdir='/fs/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/sg_0.7/test/bin8/init_ref/'    # Main subtomogram averaging directory
paramfilename='params/subtomo_param.star'          # Relative path to stopgap parameter file. 





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
    submit_cmd="mpiexec -np ${n_cores} ${subtomo} ${rootdir} ${paramfilename} ${n_cores}  2> ${rootdir}/error_stopgap 1> ${rootdir}/log_stopgap &"
    # echo ${submit_cmd}


elif [ "${run_type}" = "sge" ]; then
    echo "Preparing to run stopgap on SGE-cluster..."

    # Write submission script
    echo "#! /usr/bin/env bash" > submit_stopgap
    echo "#$ -pe openmpi ${n_cores}" >> submit_stopgap             # Number of cores
    echo "#$ -l h_vmem=${mem_limit}" >> submit_stopgap             # Memory limit
    echo "#$ -l h_rt=${wall_time}" >> submit_stopgap               # Wall time
    echo "#$ -q ${queue}" >> submit_stopgap                        # Averaging queue
    echo "#$ -e ${rootdir}/error_stopgap" >> submit_stopgap        # Error file
    echo "#$ -o ${rootdir}/log_stopgap" >> submit_stopgap          # Log file
    echo "#$ -S /bin/bash" >> submit_stopgap                       # Submission environment
    echo "source ~/.bashrc" >> submit_stopgap                      # Get proper envionment; i.e. modules
    echo "mpiexec -np ${n_cores} ${subtomo} ${rootdir} ${paramfilename} ${n_cores}" >> submit_stopgap
    echo "exit" >> submit_stopgap
    
    # Make executable
    chmod +x submit_stopgap
    
    # Submission command
    submit_cmd="qsub submit_stopgap"


elif [ "${run_type}" = "slurm" ]; then
    echo "Preparing to run stopgap on slurm-cluster..."

    # Convert seconds to minutes, taking the ceiling
    wall_time=$(((($wall_time-1)/60)+1))

    # Write submission script
    echo "#! /usr/bin/env bash" > submit_stopgap
    echo "#SBATCH -D ${rootdir}" >> submit_stopgap
    echo "#SBATCH -e error_stopgap" >> submit_stopgap
    echo "#SBATCH -o log_stopgap" >> submit_stopgap
    echo "#SBATCH -J stopgap_subtomo" >> submit_stopgap
    echo "#SBATCH --partition=${queue} " >> submit_stopgap
    echo "#SBATCH --ntasks=${n_cores}" >> submit_stopgap
    echo "#SBATCH --mem-per-cpu=${mem_limit}" >> submit_stopgap
    echo "#SBATCH --time=${wall_time}" >> submit_stopgap
    echo "srun ${subtomo} ${rootdir} ${paramfilename} ${n_cores}" >> submit_stopgap

    # Make executable
    chmod +x submit_stopgap
    
    # Submission command
    submit_cmd="sbatch submit_stopgap"

else
    echo 'ACHTUNG!!! Invalid run_type!!!'
    echo 'Only supported run_types are "local", "sge", and "slurm"!!!'
    exit 1
fi



# Run watcher
eval "${watcher} ${rootdir} ${paramfilename} ${n_cores} '${submit_cmd}'"
rm -f submit_stopgap

exit




