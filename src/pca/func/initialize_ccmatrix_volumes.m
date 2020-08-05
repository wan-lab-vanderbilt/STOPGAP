function v = initialize_ccmatrix_volumes(p,o,idx)
%% initialize_ccmatrix_volumes
% Initializing volumes for calculating CC-matrices.
%
% WW 06-2019

%% Initialize volumes

% Empty box
box = zeros(o.boxsize,'single');

% Initialize volume struct
v = struct();

% Iniitalize A and B sub-structs
if sg_check_param(p(idx),'noise_corr')
    v.A = struct('idx',-1,'ft_subtomo',box,'rand_ft',box,'filter',box);
    v.B = struct('idx',-1,'ft_subtomo',box,'rand_ft',box,'filter',box);
else
    v.A = struct('idx',-1,'ft_subtomo',box,'filter',box);
    v.B = struct('idx',-1,'ft_subtomo',box,'filter',box);
end





