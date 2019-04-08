#!/usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## extract_subtomo.sh
# Submission script for performing subtomogram extraction.
# Submission script is written for a SGE cluster and using openmpi to launch the job arrays.
#
# To use, copy this script in the subtomogram averaging folder and run!
#
# WW 07-2017

##### EXTRACTION OPTIONS #####
rootdir='/path/to/averaging/folder/'    # Subtomogram averaging folder
tomo_folder='/path/to/tomograms/'                 # Tomogram folder
tomo_digits=1                                                                           # Number of digits in tomogram name
tomo_row=7                                                                              # Row in the motivelist that contains tomogram number
subtomoname='./subtomograms/subtomo'                                                     # Relative path and name of subtomograms, with respect to main folder
subtomo_digits=1                                                                        # Number of digits for subtomogram names
allmotlfileanme='./combinedmotl/allmotl_1.em'                                           # Relative path to allmotl file
subtomosize=64                                                                          # Edge size of subtomogram in pixels
statsname='./stats/stats'                                                               # Greyvalue statistics
checkjobdir='./checkjobs/'                                                             # Checkjob directory
n_cores=1                                                                                   # Number of cores


################################################################################################################################################################
echo "Check, check, double check..."

##### PATHS #####
stopgap_path=""
extract="${stopgap_path}stopgap_extract_subtomograms_mpi.sh"


##### CHECK CHECK #####
# Check root directory
cd $rootdir
# Remove old submission files
rm -rf submit_extract

# Initialize blank folder
rm -rf blank
mkdir blank

# Check checkjobs folder
if [ ! -d $checkjobdir ]; then
    mkdir $checkjobdir
fi
if [ "$(ls -A $checkjobdir)" ]; then
    echo "CHECKJOB FOLDER NOT EMPTY!!1!! (╯°□°）╯︵ ┻━┻"
    rsync -a --delete ./blank/ $checkjobdir
    echo "CHECKJOB FOLDER CLEARED"
fi
mkdir ${checkjobdir}/start/
mkdir ${checkjobdir}/done/


echo "     (~‾▿‾)~ BEGIN EXTRACTION ~(‾▿‾~)"

eval "mpiexec -np  $n_cores $extract $rootdir $tomo_folder $tomo_digits $tomo_row $subtomoname $subtomo_digits $allmotlfileanme $subtomosize $statsname $checkjobdir"

exit
