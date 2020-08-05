function [data,header] = sg_mrcread(mrc_name)
%% sg_mrcread
% A function to read a .mrc file accoding to the IMOD formatting
% definitions. Extended headers are ignored.
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
if fid == -1
    error(['ACHTUNG!!! Error opening ',mrc_name]);
end


%% Read .mrc file

% Read header
[fid,header] = sg_fread_mrcheader(fid);

% Skip extended header
fseek(fid,(1024+header.next),'bof');%go to end end of extended Header

% Read data
nx = double(header.nx); % Conversion required for larger files.
ny = double(header.ny);
nz = double(header.nz);
n_pixels = nx*ny*nz;

switch header.mode
    case 0
        data = fread(fid,n_pixels,'int8=>int8');
    case 1
        data = fread(fid,n_pixels,'int16=>int16');
    case 2
        data = fread(fid,n_pixels,'single=>single');
end
data = reshape(data,[nx,ny,nz]);

fclose(fid);

















