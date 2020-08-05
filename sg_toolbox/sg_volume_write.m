function sg_volume_write(filename, data)
%% sg_volume_rwrite
% Write a .mrc or .em volume. This function parses the filename and
% attempts to find the proper function for the read. 
%
% WW 12-2018

%% Read volume

% Parse filename
[~,~,ext] = fileparts(filename);

% Read volume
switch ext
    case {'.map','.mrc','.rec','.st'}
        sg_mrcwrite(filename,data);
    case {'.em'}
        sg_emwrite(filename,data);
end



