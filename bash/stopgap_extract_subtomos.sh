#!/usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## extract_subtomo.sh
# Submission script for performing subtomogram extraction.
# Submission script is written for local extraction using openmpi to launch the job arrays.
#
# To use, copy this script in the subtomogram averaging folder and run!
#
# WW 07-2017

##### EXTRACTION OPTIONS #####
rootdir='/fs/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/sg_0.7/test/bin8/init_ref/' # Subtomogram averaging folder
motl_name='allmotl_1.star'                                                                 # Name of motivelist
tomo_dir='/fs/pool/pool-plitzko/will_wan/HIV_testset/tomo/flo/bin8_novactf/'  # Tomogram folder
tomo_digits=1                                                                              # Number of digits in tomogram name
subtomo_name='subtomo'                                                                     # Root-name of subtomograms.
subtomo_digits=1                                                                           # Number of digits in subtomogram names
boxsize=64                                                                                 # Size of subtomograms
pixelsize=14.24                                                                                # Pixelsize of tomogram in Angstroms
n_cores=3                                                                                  # Number of cores


################################################################################################################################################################
echo "Preparing for subtomogram extraction..."

##### PATHS #####
extract="${STOPGAPHOME}/bin/stopgap_extract_mpi.sh"

##### CHECK CHECK #####
# Check root directory
cd $rootdir

# Clear comm_dir
rm -f ${comm_dir-comm/}*

# Remove old parameter file
rm -rf extract_param.txt

# Remove old submission files
rm -rf submit_extract

##### WRITE PARAMETER FILE #####
echo "rootdir=${rootdir}" > extract_param.txt
echo "motl_name=${motl_name}" >> extract_param.txt
echo "tomo_dir=${tomo_dir}" >> extract_param.txt
echo "tomo_digits=${tomo_digits}" >> extract_param.txt
echo "subtomo_name=${subtomo_name}" >> extract_param.txt
echo "subtomo_digits=${subtomo_digits}" >> extract_param.txt
echo "boxsize=${boxsize}" >> extract_param.txt
echo "pixelsize=${pixelsize}" >> extract_param.txt
echo "n_cores=${n_cores}" >> extract_param.txt

echo "     (~‾▿‾)~ BEGIN EXTRACTION ~(‾▿‾~)"

eval "mpirun -np  $n_cores $extract $rootdir extract_param.txt"

exit








