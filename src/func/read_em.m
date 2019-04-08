function em = read_em(rootdir,emname)
%% read_em
% A function to read an em-file and throw an error if it doesn't work.
%
% WW 11-2017

global nn

try
    em = tom_emread([rootdir,'/',emname]);
    em = em.Value;
catch
    error([nn,'Achtung!!! Error reading: ',emname]);
end