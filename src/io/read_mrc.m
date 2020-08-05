function mrc = read_mrc(rootdir,mrcname)
%% read_mrc
% A function to read an mrc-file and throw an error if it doesn't work.
%
% WW 11-2017

try
    mrc = tom_mrcread([rootdir,'/',mrcname]);
    mrc = mrc.Value;
catch
    error(['Achtung!!! Error reading: ',mrcname]);
end