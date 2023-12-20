#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_extract_parser.sh
# This script is used to generate a properly formated STOPGAP .star parameter 
# file for subtomogram extraction. 
#
# If a tomolist is given, that will be used to define the path to tomograms, 
# ingnoring the tomodir setting. If a tomolist is not given, then a tomodir
# must be given, and all tomograms must be named as their tomo_num in the 
# input motivelist.
#
# WW 04-2021

##### INPUTS #####

# Parser options
param_name='params/extract_param.star'            # Name of the parameter .star file; if the name exists, the file is appended. File is written into the current working directory. 

# Folder options
rootdir='rootdir'    # Main subtomogram averaging folder.
tempdir='none'                                  # Relative path to temporary directory
commdir='none'                                  # Relative path to communication directory
listdir='none'                                  # Relative path to lists
metadir='none'



# File options
motl_name='motl_name.star'                      # Name of STOPGAP motivelist
wedgelist_name='wedgelist.star'                 # Name of STOPGAP wedgelist
tomolist_name='tomolist_name.txt'                            # Plain-text list containg tomogram numbers and path and filename of tomograms
tomodir='tomo_dir'                              # Folder containing tomograms

# Extraction Parameters
subtomo_name='subtomo'
boxsize=64
pixelsize=1
output_format='mrc8'




########################################################################################################################################################################################################
########## GENERATE STOPGAP .STAR FILE
########################################################################################################################################################################################################

# Path to MATLAB executables
parser="${STOPGAPHOME}/bin/stopgap_parser.sh"


# Run parser
eval "${parser} extract param_name ${param_name} rootdir ${rootdir} tempdir ${tempdir} commdir ${commdir} listdir ${listdir} metadir ${metadir} motl_name ${motl_name} wedgelist_name ${wedgelist_name} tomolist_name ${tomolist_name} tomodir ${tomodir} subtomo_name ${subtomo_name} boxsize ${boxsize} pixelsize ${pixelsize} output_format ${output_format}"

exit
