## stopgap_prepare_mcr.sh
# A script to setup a temporary local directory for intializing the 
# MATLAB MCR prior to running STOPGAP. This script ensures that the
# temporary folder is removed, even if the job crashes.
# 
# WW 01-2024

# Parse input arguments
args=("$@")
LOCAL_TEMP_ROOT=${args[0]}

cleanup_mcr_dir()
{
    return_val=$?
    rm -rf ${MCR_CACHE_ROOT}
    exit ${return_val}
}
#{
#  
#  if [[ $MCR_CACHE_ROOT == /tmp/u${UID}.MCR.* ]]; then
#    rm -rf ${MCR_CACHE_ROOT}
#  fi
#  exit ${return_val}
#}


export MCR_CACHE_ROOT=$(mktemp -d ${LOCAL_TEMP_ROOT}/u${UID}.MCR.XXXX)
trap 'cleanup_mcr_dir' EXIT

