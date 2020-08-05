#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_subtomo_parser.sh
#
# This script is used to generate a properly formated stopgap .star parameter 
# file for subtomogram alignment and averaging. Parameter files also keep track
# of completed iterations; when the  same parameter filename is used, the old 
# file is appended. The appended  file can be used directly; completed 
# iterations are not repeated.
#
# There are two main job types: alignment (ali) or averaging (avg) jobs. For 
# each, there are three subtypes: single reference (singleref), multireference
# (multiref), and multiclass (multiclass). Singleref jobs are standard jobs, 
# multiref jobs are where each subtomogram is aligned against multiple 
# references, and multiclass jobs are where a motl file contains multiple 
# classes, each of which is only aligned it's own reference.
#
# Last updated for STOPGAP 0.6.1
# WW 12-2018

##### INPUTS #####

# Parameter file name
param_name='params/subtomo_mra_param.star'

# Directory options
rootdir='/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/subtomo/mixedCTF/bin2/sg_0.7/'  # Root subtomogram averaging directory
tempdir='none'                                  # Relative path to temporary directory
commdir='none'                                  # Relative path to communication directory
rawdir='none'                                   # Relative path to raw files
refdir='none'                                   # Relative path to references
maskdir='none'                                  # Relative path to masks
listdir='none'                                  # Relative path to lists
fscdir='none'                                   # Relative path to FSCs
subtomodir='none'                               # Relative path to subtomograms
metadir='none'                                  # Relative path to metadata folder

# Job parameters
subtomo_mode='ali_multiref'                    # Subtomogram averaging mode (see above)
startidx=5                                      # Starting index (i.e. motivelist to be read)
iterations=30                                    # Number of iterations with current parameters
binning=2                                       # Binning factor of subtomograms

# Main file options
motl_name='allmotl_shc'                             # Rootname of motivelist. Filenames will be [motlname]_[iteration].star.
ref_name='ref_shc'                                  # Rootname of reference. Output names will be [reffilename]_[iteration].em or [reffilename]_[class]_[iteration].em.
mask_name='mask.mrc'
ccmask_name='ccmask.mrc'                        # Filename of cross-correlation mask. Required for FLCF-based scoring. Set to 'none' for no ccmask.
wedgelist_name='wedgelist.star'                 # Filename of wedgelist.
subtomo_name='subtomo'                          # Rootname of subtomograms. Filenames are [subtomoname]_[subtomo_num].em

# External filters
ali_reffilter_name='none'                        # Relative path and rootname of alignment reference filter. Set to 'none' for no filter.
ali_particlefilter_name='none'                   # Relative path and rootname of alignment reference filter. Set to 'none' for no filter.
avg_reffilter_name='none'                        # Relative path and rootname of averaging reference filter. Set to 'none' for no filter.
avg_particlefilter_name='none'                   # Relative path and rootname of averaging reference filter. Set to 'none' for no filter.
reffiltertype='none'                            # Reference filter type (subtomo or tomo). Set to 'none' for no filter.
particlefiltertype='none'                       # Particle filter type (subtomo or tomo). Set to 'none' for no filter.

# Spectral options
specdir='none'
ps_name='none'                       # Rootname of power spectrum. Calculated from aligned subtomograms.
amp_name='none'                     # Rootname of reference amplitude. Calculated from reference.
specmask_name='none'                     # Relative path and filename of spectral mask. Applied to aligned subtomogramms for powerspecra and reference for reference amplitudes.

# Search mode
search_mode='shc'                               # 'hc' is a normal greedy search. 'shc' for stochastic hill climbing approach.
# Angular search options
search_type='cone'                              # Alignment search type. Options are 'euler' or 'cone'.
# Arbitrary Euler options
euler_axes='zxy'                                # Euler axes
euler_1_incr=1                                  # Angular increment for Euler angle 1 in degrees.
euler_1_iter=1                                  # Number of angular iterations for Euler angle 1.
euler_2_incr=1                                  # Angular increment for Euler angle 2 in degrees.
euler_2_iter=3                                  # Number of angular iterations for Euler angle 2.
euler_3_incr=1                                  # Angular increment for Euler angle 3 in degrees.
euler_3_iter=1                                  # Number of angular iterations for Euler angle 3.
# Cone search options
angincr=2                                       # Angular increment for cone-search in degrees.
angiter=1                                       # Angular iterations for cone-search. 
phi_angincr=2                                   # Angular increment for in-plane search in degrees.
phi_angiter=1                                   # Angular iterations for in-plane search.
cone_search_type='coarse'                       # Cone-search type. Options are 'coarse' and 'complete'.

# Bandpass filter options
lp_rad=17                                       # Low pass filter radius in Fourier pixels.
lp_sigma=3                                      # Low pass filter dropoff in Fourier pixels.
hp_rad=1                                        # High pass filter radius in Fourier pixels.
hp_sigma=2                                      # High pass filter dropoff in Fourier pixels.

# Other filters
calc_exp=1                                      # Apply exposure-filtering to wedge mask
calc_ctf=1                                      # Apply CTF-filtering to wedge mask
cos_weight=0                                    # Weight tilt-slices by cosine of tilt angle.
score_weight=0.01                                 # Score-based weighitng. To disable, set to 1. The input number sets the attenuation factor for the poorest scoring subtomogram at unbinned Nyquist. To compensate for defocus-related scoring differences, scoring ratios are calculated on a per-tomogram basis.

# Other inputs
symmetry='C1'                                         # N-fold symmetry about the reference Z-axis.
apply_laplacian=0                               # Apply laplacian transform to volumes prior to alignment
scoring_fcn='flcf'                           # Scoring function. Options are 'flcf' and 'pearson'.
score_thresh=0                                     # Scoring threshold for averaging
subset=100                                      # Percentage of subtomograms to use for alignment. For numbers smaller than 100, subsets will be pseudo-randomly assigned.
avg_mode='partial'                              # Generate average from full dataset ('full'), or only from the aligned subset ('partial'). If subset=100, this is forced as 'full'.
ignore_halfsets=1                            # Ignore halfsets during alignment.
temperature=0                               
rot_mode='linear'                           # Rotation mode. Options are 'linear' (default), or the slower but more accurate 'cubic'.
fthresh=800                                       # Fourier threshold for reweighting. Value sets the minimum weighting as a fraction of the maxium value; i.e. setting fthresh=20 means all values lower than max/20 will be set to max/20.


########################################################################################################################################################################################################
########## GENERATE STOPGAP .STAR FILE
########################################################################################################################################################################################################

# Path to MATLAB executables
parser="${STOPGAPHOME}/bin/stopgap_parser.sh"


# Run parser 
eval "${parser} subtomo param_name ${param_name} rootdir ${rootdir} tempdir ${tempdir} commdir ${commdir} rawdir ${rawdir} refdir ${refdir} maskdir ${maskdir} listdir ${listdir} fscdir ${fscdir} subtomodir ${subtomodir} metadir ${metadir} subtomo_mode ${subtomo_mode} startidx ${startidx} iterations ${iterations} motl_name ${motl_name} wedgelist_name ${wedgelist_name} binning ${binning} ref_name ${ref_name} subtomo_name ${subtomo_name} mask_name ${mask_name} ccmask_name ${ccmask_name} ali_reffilter_name ${ali_reffilter_name} ali_particlefilter_name ${ali_particlefilter_name} avg_reffilter_name ${avg_reffilter_name} avg_particlefilter_name ${avg_particlefilter_name} reffiltertype ${reffiltertype} particlefiltertype ${particlefiltertype} specdir ${specdir} ps_name ${ps_name} amp_name ${amp_name} specmask_name ${specmask_name} search_mode ${search_mode} search_type ${search_type} euler_axes ${euler_axes} euler_1_incr ${euler_1_incr} euler_1_iter ${euler_1_iter} euler_2_incr ${euler_2_incr} euler_2_iter ${euler_2_iter} euler_3_incr ${euler_3_incr} euler_3_iter ${euler_3_iter} angincr ${angincr} angiter ${angiter} phi_angincr ${phi_angincr} phi_angiter ${phi_angiter} cone_search_type ${cone_search_type} apply_laplacian ${apply_laplacian} scoring_fcn ${scoring_fcn} lp_rad ${lp_rad} lp_sigma ${lp_sigma} hp_rad ${hp_rad} hp_sigma ${hp_sigma} calc_exp ${calc_exp} calc_ctf ${calc_ctf} cos_weight ${cos_weight} score_weight ${score_weight} symmetry ${symmetry} score_thresh ${score_thresh} subset ${subset} avg_mode ${avg_mode} ignore_halfsets ${ignore_halfsets} temperature ${temperature} rot_mode ${rot_mode} fthresh ${fthresh}"
exit



