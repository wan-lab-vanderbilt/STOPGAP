#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_job_parser.sh
# 'Stopgap' is an implementation of the TOM/AV3 package for subtomogram 
# averaging. Subtomogram alignment and averaging are performed by a single
# executable; parameters for this executable is given using a .star file. 
#
# This script is used to generate a properly formated stopgap .star parameter 
# file. Parameter files also keep track of completed iterations; when the  same
# parameter filename is used, the old file is appended. The appended  file can
# be used directly; completed iterations are not repeated.
#
# There are two main job types: alignment (ali) or averaging (avg) jobs. For 
# each, there are three subtypes: single reference (singleref), multireference
# (multiref), and multiclass (multiclass). Singleref jobs are standard jobs, 
# multiref jobs are where each subtomogram is aligned against multiple 
# references, and multiclass jobs are where a motl file contains multiple 
# classes, each of which is only aligned it's own reference.
#
# WW 01-2018

##### INPUTS #####

# Parser options
paramfilename='param.star'            # Name of the parameter .star file; if the name exists, the file is appended. File is written into the current working directory. 

# Job parameters
startidx=1                            # Starting index for jobs to parse
iterations=1                          # Number of iterations. For averaging jobs, this is forced to 1.
subtomo_mode='ali_singleref'          # Job type. [main type]_[subtype]

# Main file options
rootdir='/path/to/averaging/folder/'    # Main subtomogram averaging folder.
checkjobdir='checkjobs/'                     # Relative path to checkjob folder
completedir='complete/'                      # Relative path to completion folder
allmotlname='combinedmotl/allmotl'           # Relative path and root name of complete motivelist. The name used in each iteratio is [rootdir]/[allmotlfilename]_[iteration].em.
splitmotlname='motls/motl'                   # Relate path and root name for split motivelists; these are written for each subtomogram during alignment. 
subtomoname='subtomograms/subtomo'           # Relative path and root name of subtomograms   
subtomozeros=1                               # Leading zeros for subtomogram numbers. Set to '1' for no leading zeros.

# Wedge parameters
wedgelistname='otherinputs/wedgelist.em'     # Relative path to wedgelist  
wedgelist_type='wedge'                       # Wedgelist types are "wedge" (.em) or "slice" (.mat)
tomorow='7'                                  # Motivelist row containing tomogram number
calc_ctf='false'                              # Calcualte CTF filter for reference. Only for slice wedgelist types. 
calc_exposure='false'                         # Calcualte exposure filter for reference. Only for slice wedgelist types. 

# Masks
maskname='otherinputs/mask.em'               # Relative path to alignment mask.
ccmaskname='otherinputs/ccmask.em'           # Relative path to cross-correlation mask.

# Reference files
ali_refilename='ref/refA'                     # Relative path and rootname of reference to be used for alignment.
weighted_refilename='none'                # Relative path and rootname for a AV3-style wedge weighted reference. Set to 'none' to skip this step.
filtered_refilename='ref/refA'                   # Relative path and rootname for reference generated using reference and particle filters. 

# Bandpass filter parameters
bp_input_type='fourier'                      # Format of bandpass filters: can be given in either real-space resolution 'real' or Fourier pixels 'fourier'. Real-space parameters will be rounded to the nearest Fourier pixel.
lp_rad=13                                    # Low-pass filter radius in Fourier pixels or approximate real space resolution. To calculate resolution: (pixelsize*boxsize)/pixels.
lp_sigma=3                                   # Low-pass filter sigma. For real space, give a resolution cutoff. 
hp_rad=1                                     # High-pass filter radius.
hp_sigma=2                                   # High-pass filter sigma.

# External filter parameters
alignment_filtername='none'                  # Relative path and name of special alignment filter. For alignment_filtertype 'constant', this is a complete name, and for 'iterative', this is a rootname. The alignment filter is rotated with the same angles as the reference during subtomogram alignment.
alignment_filtertype='iterative'             # Type of alignment filter. Either 'constant' or 'iterative'.
ali_reffiltername='none'                     # Relative path and root name of special reference filter for alignment
ali_particlefiltername='none'                # Relative path and root name of special particle filter for alignment
avg_reffiltername='none'                     # Relative path and root name of special reference filter for averaging
avg_particlefiltername='none'                # Relative path and root name of special particle filter for averaging
reffiltertype='none'                         # Filter type for reference filters; options are none, tomo, subtomo for no filter, a per tomogram filter, and a per subtomogram filter
particlefiltertype='none'                    # Filter type for subtomogram filters; options are none, tomo, subtomo for no filter, a per tomogram filter, and a per subtomogram filter

# Spectral volumes
psfilename='none'                            # Relative path and root name of output powerspectum. Powerspectrum is the sum of the amplitudes of the aligned subtomograms. 
ampfilename='none'                           # Relative path and root name of output amplitude spectrum. The ampiltude spectrum is calculated from the weighted reference; the filtered reference has priority.
psmaskname='none'                            # Relative path and name of mask for subtomograms or the reference prior to Fourier transforms. This mask should have gaussian dropoffs.

# Angular search type
search_type='cone'                           # Search type. Cone search 'cone' provides efficient even sampling. Arbitrary euler triples 'euler' can also be provided for more defined local searches. 
# Euler search
euler_axes='zxy'                             # Arbitrary euler triplet. Provide three axes without spaces; i.e. 'zxz'. This defines the first,second, and third angle from the reference frame.
euler_1_incr='1'                             # Increment size for first Euler axis in degrees. 
euler_1_iter='1'                             # Number of steps about first Euler axis; i.e. iter 3 and incr 2 = -6,-4,-2,0,2,4,6.
euler_2_incr='0.5'                             # Increment size for second Euler axis in degrees. 
euler_2_iter='2'                             # Number of steps about second Euler axis.
euler_3_incr='0'                             # Increment size for third Euler axis in degrees. 
euler_3_iter='0'                             # Number of steps about third Euler axis.
# Cone search 
angincr=2                                    # Angular increment for cone search.
angiter=1                                    # Angular iterations for cone search. 
phi_angincr=2                                # Angular increment for phi search. The angles go from (-phi_angincr*phi_angiter):phi_angincr:(phi_angincr*phi_angiter)
phi_angiter=1                                # Angular iterations for phi search. 
cone_search_type='coarse'                    # Algorithm for generating cone-search angles. Options are 'coarse', which is similar to the DYNAMO/AV3 method and provides coarser sampling at larger theta angles, or 'complete' which provides true even sampling.

# Scoring function
scoring='flcf_weighted'                   # Scoring function. Options are 'flcf', 'flcf_weighted', and 'pearson'.

# Other options
pixelsize=1.64                               # Pixelsize in Angstroms
nfold=1                                      # Symmetry about the Z-axis.
threshold=0                                  # CCC threshold. All subtomograms are aligned regardless of threshold; only subtomogram with CCC >= threshold are in the final average.
iclass=0                                     # Classes to include during alignment. Setting to 0 uses all classes.
fthresh=0                                    # Fourier precentile threshold cutoff. If 0, no cutoff is used, if 100, no filtering is done. Value is forced to an integer.
writefilt=0                                  # Write filters and unfiltered reference. 1 = write, 0 = don't write.

# Parallelization options
total_cores=20
n_cores_ali=20
n_cores_aver=20



########################################################################################################################################################################################################
########## GENERATE STOPGAP .STAR FILE
########################################################################################################################################################################################################
# Path to MATLAB executable
stopgap_path=""
parser="${stopgap_path}stopgap_parser.sh"


# Run parser
eval "${parser} paramfilename ${paramfilename} rootdir ${rootdir} checkjobdir ${checkjobdir} completedir ${completedir} subtomo_mode ${subtomo_mode} startidx ${startidx} iterations ${iterations} allmotlname ${allmotlname} splitmotlname ${splitmotlname} wedgelistname ${wedgelistname} wedgelist_type ${wedgelist_type} tomorow ${tomorow} calc_ctf ${calc_ctf} calc_exposure ${calc_exposure} subtomoname ${subtomoname} subtomozeros ${subtomozeros} ali_refilename ${ali_refilename} alignment_filtername ${alignment_filtername} alignment_filtertype ${alignment_filtertype} weighted_refilename ${weighted_refilename} filtered_refilename ${filtered_refilename} maskname ${maskname} ccmaskname ${ccmaskname} ali_reffiltername ${ali_reffiltername} ali_particlefiltername ${ali_particlefiltername} avg_reffiltername ${avg_reffiltername} avg_particlefiltername ${avg_particlefiltername} reffiltertype ${reffiltertype} particlefiltertype ${particlefiltertype} writefilt ${writefilt} psfilename ${psfilename} ampfilename ${ampfilename} psmaskname ${psmaskname} search_type ${search_type} euler_axes ${euler_axes} euler_1_incr ${euler_1_incr} euler_1_iter ${euler_1_iter} euler_2_incr ${euler_2_incr} euler_2_iter ${euler_2_iter} euler_3_incr ${euler_3_incr} euler_3_iter ${euler_3_iter} angincr ${angincr} angiter ${angiter} phi_angincr ${phi_angincr} phi_angiter ${phi_angiter} cone_search_type ${cone_search_type} scoring ${scoring} bp_input_type ${bp_input_type} lp_rad ${lp_rad} lp_sigma ${lp_sigma} hp_rad ${hp_rad} hp_sigma ${hp_sigma} pixelsize ${pixelsize} nfold ${nfold} threshold ${threshold} iclass ${iclass} fthresh ${fthresh} total_cores ${total_cores} n_cores_ali ${n_cores_ali} n_cores_aver ${n_cores_aver}"

exit
