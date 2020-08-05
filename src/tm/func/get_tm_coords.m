function o = get_tm_coords(p,o,idx)
%% get_tm_coords
% Using a tomogram header, calculate coordinates for tile extraction. 
%
% WW 01-2019

%% Initialize

% % Parse full boxsize
% if sg_check_param(o,'full_tmpl_size')
%     padsize = o.full_tmpl_size;
% else
%     padsize = o.tmpl_size;
% end

% Parse full tilesize
if sg_check_param(o,'full_tilesize')
    tilesize = o.full_tilesize;
else
    tilesize = o.tilesize;
end

% Actual tomogram size
tomo_size = o.tomo_size;



%% Calcualte tiles

% Box starting indices
starts = cell(3,1);
for i =1:3
    if sg_check_param(p(idx),'tomo_mask_name')
        starts{i} = ceil(linspace(o.bounds(1,i),o.bounds(2,i),o.grid(i)+1));
    else
        starts{i} = ceil(linspace(1,o.tomo_size(i),o.grid(i)+1));
    end
end

% Box ending indices
ends = cell(3,1);
for i =1:3
    ends{i} = starts{i}(1:end-1) + diff(starts{i}) - 1;
    ends{i}(end) = ends{i}(end) + 1;
end

% Box grid
[sx,sy,sz] = ndgrid(starts{1}(1:end-1),starts{2}(1:end-1),starts{3}(1:end-1));
[ex,ey,ez] = ndgrid(ends{1},ends{2},ends{3});

% Box start
bs = cat(2,sx(:),sy(:),sz(:));
be = cat(2,ex(:),ey(:),ez(:));
n_tiles = size(bs,1);


% Check ends
for i = 1:3
    temp_idx = be(:,i) > tomo_size(i);
    be(temp_idx,i) = tomo_size(i);
end

% Size of tiles
t_size = be - bs + 1;


%% Calculate extraction positions

% Extraction start
es = bs - repmat(floor(o.padsize/2),[n_tiles,3]);
ee = es + repmat(tilesize-1,[n_tiles,1]);


% Pasted tile indices
ts = ones(n_tiles,3);
te = repmat(tilesize,[n_tiles,1]);


% Check for out of starting bounds
d_start = 1-es;                 % Difference between tomogram and extraction starts
d_start_idx = d_start > 0;      % Index of out-of-bound extraction starts
ts(d_start_idx) = ts(d_start_idx) + d_start(d_start_idx);   % Starting position of where to paste tile
es(d_start_idx) = 1;            % Set out-of-bound extraction starts to 1


% Check for out of starting bounds
end_array = repmat(tomo_size,[n_tiles,1]);  % Tomogram limits
d_end = end_array - ee;                     % Differene between tomogram and extraction ends
d_end_idx = d_end < 0;                      % Index of out-of-bound extraction ends        
ee(d_end_idx) = end_array(d_end_idx);       % Set out-of-bound extraction ends to tomogram limits
te(d_end_idx) = te(d_end_idx) + double(d_end(d_end_idx));


%% Calculate tiles from CC map

cs = repmat(floor(o.padsize/2)+1,[n_tiles,3]);    % Crop start
ce = cs + t_size - 1;                           % Crop end

%% Store arrays

% Coordinate struct
c = struct();
c.bs = bs;          % Box coordinates (where the central boxes are in the tomogram)
c.be = be;
c.es = es;          % Extraction positions for padded tiles from the tomogram
c.ee = ee;
c.ts = ts;          % Pasting coordinates for the tiles
c.te = te;
c.cs = cs;          % Cropping coordinates from tiles (returns box for pasting into new tomogram)
c.ce = ce;


% Fill 'o' struct
o.c = c;
o.n_tiles = n_tiles;
% o.tomo_size = tomo_size;






