## stopgap_prepare_local_temp.sh
# A script to setup a temporary local temporary directory 
# for copying input data. 
# 
# WW 03-2021


cleanup_temp_dir()
{
  return_val=$?
  if [[ $LOCAL_TEMP == /tmp/stopgap_u${UID}_j${SLURM_JOB_ID} ]]; then
    rm -rf ${LOCAL_TEMP}
  fi
  exit ${return_val}
}


# export LOCAL_TEMP="/tmp/stopgap_u${UID}_j${SLURM_JOB_ID}"
export LOCAL_TEMP="/tmp/stopgap_u${UID}"
mkdir -p $LOCAL_TEMP/copy_comm/
trap 'cleanup_temp_dir' EXIT

