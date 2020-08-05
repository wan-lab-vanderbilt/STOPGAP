#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_pca_job_parser.sh
#
# This script is used to generate a properly formated STOPGAP PCA parameter file.
# The paramter file is plain-text file that contains the necessary information for
# a complete PCA run; the old file is completely overwritten when the parser is 
# run. 
#
# WW 05-2019

##### INPUTS #####

# Parameter file name
param_name='params/pca_param.txt'


# Directory options
rootdir='/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/tm/sg_0.7/'  # Root subtomogram averaging directory
tempdir='none'                                  # Relative path to temporary directory
commdir='none'                                  # Relative path to communication directory
rawdir='none'                                   # Relative path to raw files
refdir='none'                                   # Relative path to references
maskdir='none'                                  # Relative path to masks
listdir='none'                                  # Relative path to lists
subtomodir='none'                               # Relative path to subtomograms
rvoldir='none'                                  # Relative path to pre-rotated volumes
pcadir='none'                                   # Relative path to PCA-related files
metadir='none'

# PCA task
pca_task='pre_rot'

# Alignment parameters
iteration=8
motl_name='allmotl'
wedgelist_name='wedgelist.star'
binning=4

# Volume parameters
ref_name='ref'
mask_name='mask.mrc'
subtomo_name='subtomo'
rvol_name='rvol'
rwei_name='rwei'

# PCA parameters
filtlist_name='filter_list.star'
data_type='awpd'
ccmat_name='ccmatrix'
covar_name='covar'
n_eigs=10
eigenvol_name='eigenvol'
eigenfac_name='eigenfac'
eigenval_name='eigenval'

# Other parameters
apply_laplacian=0
scoring_fcn='pearson'     # Options are 'pearson' or 'laplacian'
symmetry=c1
fthresh=300


########################################################################################################################################################################################################
########## GENERATE STOPGAP PCA PARAMETER FILE
########################################################################################################################################################################################################

# Path to MATLAB executables
parser="${STOPGAPHOME}/bin/stopgap_parser.sh"


# Run parser 
eval "${parser} pca param_name ${param_name} rootdir ${rootdir} tempdir ${tempdir} commdir ${commdir} rawdir ${rawdir} refdir ${refdir} maskdir ${maskdir} listdir ${listdir} subtomodir ${subtomodir} rvoldir ${rvoldir} pcadir ${pcadir} metadir ${metadir} pca_task ${pca_task} iteration ${iteration} motl_name ${motl_name} wedgelist_name ${wedgelist_name} binning ${binning} ref_name ${ref_name} mask_name ${mask_name} subtomo_name ${subtomo_name} rvol_name ${rvol_name} rwei_name ${rwei_name} filtlist_name ${filtlist_name} data_type ${data_type} ccmat_name ${ccmat_name} covar_name ${covar_name} n_eigs ${n_eigs} eigenvol_name ${eigenvol_name} eigenfac_name ${eigenfac_name} eigenval_name ${eigenval_name} apply_laplacian ${apply_laplacian} scoring_fcn ${scoring_fcn} symmetry ${symmetry} fthresh ${fthresh}"
exit







