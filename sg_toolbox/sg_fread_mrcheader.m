function [fid,header] = sg_fread_mrcheader(fid)
%% sg_fread_mrcheader
% A function to read the header from an opened mrc file. 
%
% WW 06-2018

%% Read header
header = struct();

% Dimensions (Colums, Rows, Sections)
header.nx = fread(fid,1,'int=>int');        %integer: 4 bytes
header.ny = fread(fid,1,'int=>int');        %integer: 4 bytes
header.nz = fread(fid,1,'int=>int');        %integer: 4 bytes

% Data mode
header.mode = fread(fid,1,'int=>int');      %integer: 4 bytes

% Starting point of sub-image (not used in IMOD)
header.nxstart= fread(fid,1,'int=>int');    %integer: 4 bytes
header.nystart= fread(fid,1,'int=>int');    %integer: 4 bytes
header.nzstart= fread(fid,1,'int=>int');    %integer: 4 bytes

% Grid size in x,y,z
header.mx= fread(fid,1,'int=>int');         %integer: 4 bytes
header.my= fread(fid,1,'int=>int');         %integer: 4 bytes
header.mz= fread(fid,1,'int=>int');         %integer: 4 bytes

% Cell size in Angstroms. (pixel spacing = xlen/mx ylen/my, zlen/mz)
header.xlen= fread(fid,1,'float=>float');     %float: 4 bytes
header.ylen= fread(fid,1,'float=>float');     %float: 4 bytes
header.zlen= fread(fid,1,'float=>float');     %float: 4 bytes

% Cell angles (ignored in IMOD)
header.alpha= fread(fid,1,'float=>float');    %float: 4 bytes
header.beta= fread(fid,1,'float=>float');     %float: 4 bytes
header.gamma= fread(fid,1,'float=>float');    %float: 4 bytes

% Map Column, row, and section. Must be set to 1,2,3 for correct pixel spacing.
header.mapc= fread(fid,1,'int=>int');       %integer: 4 bytes
header.mapr= fread(fid,1,'int=>int');       %integer: 4 bytes
header.maps= fread(fid,1,'int=>int');       %integer: 4 bytes

% Data value info (must be set for proper scaling)
header.amin= fread(fid,1,'float=>float');     %float: 4 bytes
header.amax= fread(fid,1,'float=>float');     %float: 4 bytes
header.amean= fread(fid,1,'float=>float');    %float: 4 bytes

% Space group. In IMOD: 0 for stack, 1 for volume.
header.ispg= fread(fid,1,'short=>short');     %integer: 2 bytes
header.nsymbt = fread(fid,1,'short=>short');  %integer: 2 bytes

% Number of bytes in extended header
header.next = fread(fid,1,'int=>int');      %integer: 4 bytes

% Old ID number, set as 0
header.creatid = fread(fid,1,'short=>short'); %integer: 2 bytes
% header.unused1 = fread(fid,30);        %not used: 30 bytes
fseek(fid,30,'cof');

% Number of integers per section (FEI/Agard format) or number of bytes per
% section (SerialEM format)
header.nint = fread(fid,1,'short=>short');    %integer: 2 bytes

% Number of reals per section (FEI/Agard format) or bit flags for which
% types of short data (Serial EM format): 
% 1 = Tilt angle in degrees * 100 (2 bytes)
% 2 = X, Y, Z, peice coordinates for montage (6 bytes)
% 4 = X, Y stage position in microns * 25 (4 bytes)
% 8 = Magnification / 100 (2 bytes)
% 16 = Intensity * 25000  (2 bytes)
% 32 = Exposure dose in e-/A2, a float in 4 bytes
% 128, 512: Reserved for 4-byte items
% 64, 256, 1024: Reserved for 2-byte items
% If the number of bytes implied by these flags does
% not add up to the value in nint, then nint and nreal
% are interpreted as ints and reals per section
header.nreal = fread(fid,1,'short=>short');   %integer: 2 bytes

% Extra data and IMOD bitflags
% header.unused2 = fread(fid,28);        %not used: 28 bytes
fseek(fid,28,'cof');

% Some data type stuff
header.idtype= fread(fid,1,'short=>short');   %integer: 2 bytes
header.lens=fread(fid,1,'short=>short');      %integer: 2 bytes
header.nd1=fread(fid,1,'short=>short');       %integer: 2 bytes
header.nd2 = fread(fid,1,'short=>short');     %integer: 2 bytes
header.vd1 = fread(fid,1,'short=>short');     %integer: 2 bytes
header.vd2 = fread(fid,1,'short=>short');     %integer: 2 bytes
for i=1:6                             %24 bytes in total
    header.tiltangles(i)=fread(fid,1,'float=>float');%float: 4 bytes
end

% New-style MRC format (IMOD 2.6.20 and above)
% Origin of image
header.xorg = fread(fid,1,'float=>float');    %float: 4 bytes
header.yorg = fread(fid,1,'float=>float');    %float: 4 bytes
header.zorg = fread(fid,1,'float=>float');    %float: 4 bytes

% Should say "MAP "
header.cmap = fread(fid,4,'char=>char');     %Character: 4 bytes
% First two byptes of 17,17 for big-endian and 68,65 for little endian.
header.stamp = fread(fid,4,'char=>char');    %Character: 4 bytes
% RMS deviation of densities from mean. Set to -1 if not computed.
header.rms=fread(fid,1,'float=>float');       %float: 4 bytes
% Number of labels
header.nlabl = fread(fid,1,'int=>int');     %integer: 4 bytes
% Labels
labl = fread(fid,800,'char=>char');   %Character: 800 bytes


%% Parse labels

labl = reshape(labl,[80,10])';
labl_cell = cellstr(labl);
header.labl = labl_cell(1:header.nlabl);

    
