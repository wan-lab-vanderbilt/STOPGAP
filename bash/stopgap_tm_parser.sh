#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_tm_parser.sh
# This script is used to generate a properly formated STOPGAP .star parameter 
# file fo template matching. When the parser is run, a new parameter file is 
# generated, or if one already exists, it is appended.
#
# WW 01-2019

##### INPUTS #####

# Parser options
param_name='params/tm_param.star'            # Name of the parameter .star file; if the name exists, the file is appended. File is written into the current working directory. 

# Folder options
rootdir='/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/tm/sg_0.7/'    # Main subtomogram averaging folder.
tempdir='none'                                  # Relative path to temporary directory
commdir='none'                                  # Relative path to communication directory
listdir='none'                                  # Relative path to lists
tmpldir='none'                                  # Relative path to templates
maskdir='none'                                  # Relative path to masks
mapdir='none'                                   # Relative path to output maps
metadir='none'


# File options
tomolist_name='tomolist.txt'                    # Plain-text list containg path and filename of tomograms
wedgelist_name='wedgelist.star'                 # Name of STOPGAP wedgelist
tlist_name='tlist_groel.star'                         # Template list
smap_name='smap_flcf_noise1'                                # Root name of score map. Final name is [smap_name]_[tomo_num].[vol_ext]
omap_name='omap_flcf_noise1'                                # Root name of orientation map. Final name is [omap_name]_[tomo_num].[vol_ext]
tmap_name='tmap_flcf_noise1'                                # Root name of template map. Final name is [tmap_name]_[tomo_num].[vol_ext]. This is only written when more than one template used.

# Binning
binning=4

# Bandpass filter parameters
lp_rad=11                                    # Low-pass filter radius in Fourier pixels or approximate real space resolution. To calculate resolution: (pixelsize*boxsize)/pixels.
lp_sigma=3                                   # Low-pass filter sigma. For real space, give a resolution cutoff. 
hp_rad=1                                     # High-pass filter radius.
hp_sigma=2                                   # High-pass filter sigma.


# Other filters
calc_exp=1                                      # Apply exposure-filtering to wedge mask
calc_ctf=1                                      # Apply CTF-filtering to wedge mask


# Other parameters
apply_laplacian=0
noise_corr=1



########################################################################################################################################################################################################
########## GENERATE STOPGAP .STAR FILE
########################################################################################################################################################################################################

# Path to MATLAB executables
parser="${STOPGAPHOME}/bin/stopgap_parser.sh"


# Run parser
eval "${parser} temp_match param_name ${param_name} rootdir ${rootdir} tempdir ${tempdir} commdir ${commdir} listdir ${listdir} tmpldir ${tmpldir} maskdir ${maskdir} mapdir ${mapdir} metadir ${metadir} tomolist_name ${tomolist_name} wedgelist_name ${wedgelist_name} tlist_name ${tlist_name} smap_name ${smap_name} omap_name ${omap_name} tmap_name ${tmap_name} binning ${binning} lp_rad ${lp_rad} lp_sigma ${lp_sigma} hp_rad ${hp_rad} hp_sigma ${hp_sigma} calc_exp ${calc_exp} calc_ctf ${calc_ctf} apply_laplacian ${apply_laplacian} noise_corr ${noise_corr}"

exit
