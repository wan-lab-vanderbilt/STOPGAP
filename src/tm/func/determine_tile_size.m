function o = determine_tile_size(p,o,s,idx)
%% determine_tile_size
% Determine the tile size required to split a tomogram into even pieces.
%
% Bugfix by M. Obr
%
% WW 04-2023


%% Parse tomogram size

if sg_check_param(p(idx),'tomo_mask_name')
    % Use boundaries
    tomo_size = round_to_even(o.bounds(3,:));
else
    % Use actual tomogram size
    tomo_size = o.tomo_size;
end

%% Determine tile size

% Calculate non-overlapping tilesize
no_tilesize = p(idx).tilesize - o.tmpl_size;

% Calculate tile grid
o.grid = ceil(tomo_size./no_tilesize);

% Calculate patch size
o.patchsize = round_to_even(tomo_size./o.grid);


% Decide padding size on scoring algorithm
switch s.scoring_fcn
    case 'flcf'
        o.padsize = o.tmpl_size;
    case 'scf'
        o.padsize = o.tmpl_size.*2;
    otherwise
        error('ACHTUNG!!! Invalid scoring function!!!');
end

% Set tilesize
o.tilesize = o.patchsize + o.tmpl_size;

% Check tilesize against bounded tomogram
tile_bounds_idx = o.tilesize > tomo_size;
if any(tile_bounds_idx)
    o.tilesize(tile_bounds_idx) = tomo_size(tile_bounds_idx);
end


