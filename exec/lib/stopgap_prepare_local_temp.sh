## stopgap_prepare_local_temp.sh
# A script to setup a temporary local temporary directory 
# for copying input data. 
# 
# WW 01-2024

# Parse input arguments
args=("$@")
LOCAL_TEMP=${args[0]}

cleanup_temp_dir()
{
    return_val=$?
    rm -rf ${LOCAL_TEMP}
    exit ${return_val}
}


#export LOCAL_TEMP="$LOCAL_TEMP_ROOT/stopgap_u${UID}"
mkdir -p $LOCAL_TEMP/copy_comm/
trap 'cleanup_temp_dir' EXIT

