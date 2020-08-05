function o = determine_tile_size(p,o,s,idx)
%% determine_tile_size
% Determine the tile size required to split a tomogram into even pieces.
%
% WW 03-2019


%% Parse tomogram size

if sg_check_param(p(idx),'tomo_mask_name')
    % Use boundaries
    tomo_size = round_to_even(o.bounds(3,:));
else
    % Use actual tomogram size
    tomo_size = o.tomo_size;
end

%% Determine tile size

% Factorialize number of cores
f = factor(o.n_cores);
n_f = numel(f);

% Make sure number of factors is divisible by 3
if mod(n_f,3)
    f = cat(2,f,ones(1,(ceil(n_f/3)*3)-n_f));
end

% Generate smallest box counts
grid = prod(reshape(f,3,[]),2);

% % Generate average box dimensions
% [sort_tomo_size,sort_idx] = sortrows(cat(1,1:3,tomo_size)',2);
% sort_patchsize = ceil(sort_tomo_size(:,2)./sort(grid));
% patchsize = sort_patchsize(sort_tomo_size(sort_idx,1))';

% Generate average box dimensions
sort_grid = sort(grid);
[sort_tomo_size,sort_idx] = sortrows(cat(1,1:3,tomo_size)',2);
sort_patchsize = ceil(sort_tomo_size(:,2)./sort_grid-1);
patchsize = sort_patchsize(sort_tomo_size(sort_idx,1))';

% Store grid parameters
o.grid = sort_grid(sort_tomo_size(sort_idx,1));


% Round down patchsize to even
o.patchsize = round_to_even(patchsize);

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



