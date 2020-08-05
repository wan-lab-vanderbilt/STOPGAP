function data = sg_emread(filename)
%% sg_emread
% Read data from an .em file while ignoring headers. 
%
% WW 08-2018

%% Check maching type

% Open file
fid = fopen(filename,'r','ieee-le');
if fid == -1
    error(['ACHTUNG!!! Error opening ',filename]);
end

% Read basic header info
machine_id   = fread(fid,1,'uint8');
fseek(fid,2,0);
data_type      = fread(fid,1,'uint8');
fclose(fid);

% Parse machine type
switch machine_id
    case [0,3,5]
        machine_type = 'ieee-be';
    case 6
        machine_type = 'ieee-le';
    otherwise
        error('ACHTUNG!!! File has unsupported machine type!!!');
end

% Parse data type
switch data_type
    case 1
        dtype = 'char=>char';
    case 2
        dtype = 'int16=>int16';
    case 4
        dtype = 'long=>int32';
    case 5
        dtype = 'float=>single';
    case 8
        dtype = 'float32=>double';
end
    

% Open file
fid = fopen(filename,'r',machine_type);


%% Read data

% Skip initial data
fseek(fid,4,-1);

% Read data size
data_size = fread(fid,3,'int32');   % Array size
n_data = prod(data_size);           % Total number of data points

% Skip to data start
fseek(fid,512,-1);

% Read data
data = fread(fid,n_data,dtype);
data = reshape(data,round(data_size'));

% Close file
fclose(fid);







