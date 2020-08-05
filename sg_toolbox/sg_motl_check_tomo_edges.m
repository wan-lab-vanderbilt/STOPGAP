function new_motl = sg_motl_check_tomo_edges(tomo_name,motl,padding)
%% sg_motl_check_tomo_edges
% Remove motl entries outside the boundaries of a tomogram edges. Padding
% defines how far from the tomogram edges to set the boundaries. 
%
% WW 07-2018

%% Check check

if numel(padding)==1
    padding = [padding,padding,padding];
elseif numel(padding) == 2
    error('ACHTUNG!!! Padding must be either 1 or 3 numbers!!!');
end


%% Clean it up!

% Get tomogram header
header = sg_read_mrc_header(tomo_name);

% Define boundaries
x1 = 1 + padding(1);
x2 = header.nx - padding(1) - 1;
y1 = 1 + padding(2);
y2 = header.ny - padding(2) - 1;
z1 = 1 + padding(3);
z2 = header.nz - padding(3) - 1;

% Find cutoffs
x_idx = ([motl.orig_x] >= x1) & ([motl.orig_x] <= x2);
y_idx = ([motl.orig_y] >= y1) & ([motl.orig_y] <= y2);
z_idx = ([motl.orig_z] >= z1) & ([motl.orig_z] <= z2);
idx = x_idx & y_idx & z_idx;

% Return cleaned motl
new_motl = motl(idx);



