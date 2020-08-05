function o = prepare_parallel_tm(p,o,s,idx)
%% 
% Initialize job parameters for parallel template matching.
%
% WW 01-2019



%% Initialize volumes for run
disp([s.nn,'Initialing parameters for parallel template matching...']);

% Get tomogram header
header = sg_read_mrc_header(p(idx).tomo_name);

% Parse tomogram size
o.tomo_size = double([header.nx,header.ny,header.nz]);

% Check for masked regions
if sg_check_param(p(idx),'tomo_mask_name')
    o = tm_check_mask(p,o,s,idx);
elseif isfield(o,'bounds')
    o = rmfield(o,'bounds');
end


%% Generate job parameters

% % Check scoring function
% if sg_check_param(p(idx),'scoring_fcn')
%     o.scoring_fcn = p(idx).scoring_fcn;
% else
%     o.scoring_fcn = 'flcf';
% end

% Determine box sizes
o = determine_tile_size(p,o,s,idx);

% Get tile coordinates
o = get_tm_coords(p,o,idx);










