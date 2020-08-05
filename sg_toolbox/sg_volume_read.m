function vol = sg_volume_read(filename)
%% sg_volume_read
% Read a .mrc or .em volume. This function parses the filename and attempts
% to find the proper function for the read. 
%
% WW 10-2018

%% Read volume

% Parse filename
[~,~,ext] = fileparts(filename);

% Read volume
switch ext
    case {'.map','.mrc','.rec','.st'}
        vol = sg_mrcread(filename);
    case {'.em'}
        vol = sg_emread(filename);
end



