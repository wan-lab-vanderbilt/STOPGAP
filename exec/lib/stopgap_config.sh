## stopgap_config.sh
# Sources MATLAB MCR directories required to run STOPGAP.
#
# WW 06-2019


# Source MCR
matlabRoot="/fs/pool/pool-apps-rz/MATLAB_2015b"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/runtime/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/bin/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/sys/os/glnxa64/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}":$matlabRoot/sys/opengl/lib/glnxa64/"

