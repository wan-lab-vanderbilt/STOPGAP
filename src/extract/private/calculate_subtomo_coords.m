function coords = calculate_subtomo_coords(tomogram,motl,boxsize)
%% calculate_subtomo_coords
% Calcualte 


%% Calcualte coordinates

% Tomogram dimensions
[tomo_x,tomo_y,tomo_z] = size(tomogram);

% Extraction center
tc = floor(cat(1,[motl.orig_x],[motl.orig_y],[motl.orig_z]));

% Extraction starting indices
coords.es = tc - floor(boxsize/2);

% Extraction ending indices
coords.ee = coords.es + boxsize - 1;


% Subtomo indices
n_motls = numel(motl);
coords.ss = ones(3,n_motls);
coords.se = ones(3,n_motls).*boxsize;


% Check for out of starting bounds
d_start = 1-coords.es;
d_start_idx = d_start>0;
coords.ss(d_start_idx) = coords.ss(d_start_idx) + d_start(d_start_idx);
coords.es(d_start_idx) = 1;

% Check for out of starting bounds
end_array = repmat([tomo_x;tomo_y;tomo_z],[1,n_motls]);
d_end = end_array - coords.ee;
d_end_idx = d_end<0;
coords.ee(d_end_idx) = end_array(d_end_idx);
coords.se(d_end_idx) = coords.se(d_end_idx) + d_end(d_end_idx);


