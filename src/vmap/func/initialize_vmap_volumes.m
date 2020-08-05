function v = initialize_vmap_volumes(o)
%% initialize_vmap_volumes
% Initialize volume array for variance map calculation.
%
% WW 05-2019

%% Initialize volumes

% Initialize array
v = struct();

% Initialize cells
v.vmap = zeros(o.boxsize,'single');
v.wei = zeros(o.boxsize,'single');








