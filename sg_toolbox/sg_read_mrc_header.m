function header = sg_read_mrc_header(mrc_name)
%% sg_read_mrc_header
% A function read and return a .mrc header as a struct array.
%
% WW 06-2018

%% Initialize

% Check computer type
[~,~,endian] = computer;
switch endian
    case 'L'
        sysfor='ieee-le';
    case 'B'
        sysfor='ieee-be';
end

% Open file
fid = fopen(mrc_name,'r',sysfor);



%% Read .mrc file

% Read header
[fid,header] = sg_fread_mrcheader(fid);

fclose(fid);

