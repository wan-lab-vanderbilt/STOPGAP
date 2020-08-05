function vol = sg_read_mrc_subvolume(mrc_name,start_coord,end_coord)
%% sg_read_mrc_subvolume
% Read a subvolume from a .mrc file. start_coord is the bottom lower left
% corner (i.e. [1,1,1]) and the end_coord is the top upper right (i.e.
% [32,32,32]).
%
% WW 01-2018

%% Check check

if numel(start_coord) == 2
    start_coord = [start_coord(:);1]';
end
if numel(end_coord) == 2
    end_coord = [end_coord(:);1]';
end

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



%% Read header file

% Read header
[fid,header] = sg_fread_mrcheader(fid);

% Skip extended header
fseek(fid,(1024+header.next),'bof');%go to end end of extended Header

% Parse tomogram size
tomo_size = double([header.nx,header.ny,header.nz]);

% Check for out-of-bounds
if any(start_coord < 1)
    error('ACHTUNG!!! start_coord is out of bounds!!!');
end
if any(tomo_size < end_coord)
    error('ACHTUNG!!! end_coord is out of bounds!!!');
end


% Number of bytes for mode
switch header.mode
    case 0
        n_bytes = 1;
    case 1
        n_bytes = 2;
    case 2
        n_bytes = 4;
end

%% Read subvolume

% Volume size
v_size = end_coord-start_coord+1;

% Number of voxels in volume
n_pixels = prod(v_size);

% Linear volume
vol = zeros(n_pixels,1,'single');

% Counters
c = 1;                          % Current position in linear volume
data_start = ftell(fid);        % Start of .mrc data
c_pos = ftell(fid);             % Current position of fid


% Read subvolume
for z = start_coord(3):end_coord(3)
    for y = start_coord(2):end_coord(2)
            
        % Starting index of x-data line
        s_idx = (y-1)*tomo_size(1) + (z-1)*(tomo_size(1)*tomo_size(2)) + start_coord(1);
        
        % Go to start of x-data for current line
        offset = (data_start + ((s_idx -1)*n_bytes))- c_pos;    % Calculate offset of s_idx from current position in bytes
        fseek(fid,offset,'cof');

        % Read x-data line
        switch header.mode
            case 0
                temp_data = fread(fid,v_size(1),'int8=>single');
            case 1
                temp_data = fread(fid,v_size(1),'int16=>single');
            case 2
                temp_data = fread(fid,v_size(1),'single=>single');
        end

        % Store linear data
        vol(c:(c + numel(temp_data) - 1)) = temp_data;

        % Increment counters
        c = c + numel(temp_data);
        c_pos = ftell(fid);
        
    end
end


% Reshape volume
vol = reshape(vol,v_size);            
            


fclose(fid);