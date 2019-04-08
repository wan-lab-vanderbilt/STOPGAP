#! /usr/bin/env bash

## stopgap_config.sh
# A function for setting the MATLAB environment for 
# the 'stopgap' subtomogram averaging package.

#if [[  -v LD_LIBRARY_PATH  ]]; then
#    echo $LD_LIBRARY_PATH
#else
    export LD_LIBRARY_PATH=""
#fi

#if [ -z "$LD_LIBRARY_PATH" ]
#then
#   export LD_LIBRARY_PATH=""
#else
#   echo $LD_LIBRARY_PATH
#fi



# MCR
matlabRoot="/fs/pool/pool-apps-rz/MATLAB_2015b"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/runtime/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/bin/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/sys/os/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/sys/opengl/lib/glnxa64/"

