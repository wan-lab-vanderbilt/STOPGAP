function tile = read_tm_tiles(p,o,idx,file)
%% read_tm_tiles
% Read in the tiles for parallel template matching. To minimize I/O, tiles
% are read as subvolumes rather than reading the entire tomogram.
%
% WW 01-2019

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
switch file
    case 'tomo'
        fid = fopen(p(idx).tomo_name,'r',sysfor);
    case 'mask'
        fid = fopen(p(idx).tomo_mask_name,'r',sysfor);
end


% Parse full tilesize
if sg_check_param(o,'full_tilesize')
    tilesize = o.full_tilesize;
else
    tilesize = o.tilesize;
end
tile = ones(tilesize,'single');

%% Read header file

% Read header
[fid,header] = sg_fread_mrcheader(fid);

% Skip extended header
fseek(fid,(1024+header.next),'bof');%go to end end of extended Header

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

data_start = ftell(fid);        % Start of .mrc data


% Parse tile index
t = o.procnum;

% Parse extraction corners
start_coord = o.c.es(t,:);
end_coord = o.c.ee(t,:);

% Volume size
v_size = end_coord-start_coord+1;

% Number of voxels in volume
n_pixels = prod(v_size);

% Linear volume
vol = zeros(n_pixels,1,'single');

% Counters
c = 1;                          % Current position in linear volume    
c_pos = ftell(fid);             % Current position of fid


% Read subvolume
for z = start_coord(3):end_coord(3)
    for y = start_coord(2):end_coord(2)

        % Starting index of x-data line
        s_idx = (y-1)*o.tomo_size(1) + (z-1)*(o.tomo_size(1)*o.tomo_size(2)) + start_coord(1);

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

% Fill tile with mean values (for normalization)
tile = tile.*header.amean;


% Paste extracted volume
tile(o.c.ts(t,1):o.c.te(t,1),o.c.ts(t,2):o.c.te(t,2),o.c.ts(t,3):o.c.te(t,3)) = reshape(vol,v_size);

    
% Close file
fclose(fid);