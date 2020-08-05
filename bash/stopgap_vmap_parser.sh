#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_job_parser.sh
#
# This script is used to generate a properly formated stopgap .star parameter 
# file for calculating a variance map from given input references and the 
# subtomograms used to generate them.
#
# WW 05-2019

##### INPUTS #####

# Parameter file name
param_name='params/vmap_param.star'

# Directory options
rootdir='/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/tm/sg_0.7/'  # Root subtomogram averaging directory
tempdir='none'                                  # Relative path to temporary directory
commdir='none'                                  # Relative path to communication directory
rawdir='none'                                   # Relative path to raw files
refdir='none'                                   # Relative path to references
maskdir='none'                                  # Relative path to masks
listdir='none'                                  # Relative path to lists
subtomodir='none'                               # Relative path to subtomograms
metadir='none'

# Job parameters
vmap_mode='singleref'                           # Variance map mode. 'singleref' ignores classes while 'multiclass' generates a variance map for each class.
iteration=6                                           # Iteration index (i.e. motivelist to be read)
binning=4                                       # Binning factor of subtomograms


# Main file options
motl_name='allmotl'                             # Rootname of motivelist. Filenames will be [motlname]_[iteration].star.
ref_name='ref'                                  # Rootname of reference. Output names will be [reffilename]_[iteration].em or [reffilename]_[class]_[iteration].em.
vmap_name='var'                                 # Rootname of variance map. Output names will be [vmap_name]_[iteration].em or [vmap_name]_[class]_[iteration].em and stored in the refdir.
mask_name='none'                                # Filename of real-space normalization mask.
wedgelist_name='wedgelist.star'                 # Filename of wedgelist.
subtomo_name='subtomo'                          # Rootname of subtomograms. Filenames are [subtomoname]_[subtomo_num].em

# Bandpass filter options
lp_rad=22                                       # Low pass filter radius in Fourier pixels.
lp_sigma=3                                      # Low pass filter dropoff in Fourier pixels.
hp_rad=0                                        # High pass filter radius in Fourier pixels.
hp_sigma=0                                      # High pass filter dropoff in Fourier pixels.

# Other inputs
symmetry='C1'                                         # N-fold symmetry about the reference Z-axis.
score_thresh=0                                     # Scoring threshold for averaging
fthresh=300                                       # Fourier threshold for reweighting. Value sets the minimum weighting as a fraction of the maxium value; i.e. setting fthresh=20 means all values lower than max/20 will be set to max/20.



########################################################################################################################################################################################################
########## GENERATE STOPGAP .STAR FILE
########################################################################################################################################################################################################

# Path to MATLAB executables
parser="${STOPGAPHOME}/bin/stopgap_parser.sh"


# Run parser 
eval "${parser} vmap param_name ${param_name} rootdir ${rootdir} tempdir ${tempdir} commdir ${commdir} rawdir ${rawdir} refdir ${refdir} maskdir ${maskdir} listdir ${listdir} subtomodir ${subtomodir} metadir ${metadir} vmap_mode ${vmap_mode} iteration ${iteration} binning ${binning} motl_name ${motl_name} ref_name ${ref_name} vmap_name ${vmap_name} mask_name ${mask_name} wedgelist_name ${wedgelist_name} subtomo_name ${subtomo_name} lp_rad ${lp_rad} lp_sigma ${lp_sigma} hp_rad ${hp_rad} hp_sigma ${hp_sigma} symmetry ${symmetry} score_thresh ${score_thresh} fthresh ${fthresh}"
exit




