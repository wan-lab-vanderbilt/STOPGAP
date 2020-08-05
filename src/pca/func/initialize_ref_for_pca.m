function v = initialize_ref_for_pca(p,o,s,v,idx)
%% initialize_ref_for_pca
% Initialize reference for covariance calculation. The reference is
% required for the calculation of 'wedge-masked differences' (wmd), and
% 'ampolitude-weighted phase differences' (awpd).
%
% WW 06-2019

%% Check check

% Return empty struct
if strcmp(p(idx).data_type,'subtomo')
    v.ft_ref = [];    
    return
end

%% Initialize reference

% Parse name
ref_name = [o.refdir,'/',p(idx).ref_name,'_',num2str(p(idx).iteration),s.vol_ext];

% Read reference
v.ft_ref = read_vol(s,p(idx).rootdir,ref_name);

% Symmetrize reference
v.ft_ref = sg_symmetrize_volume(v.ft_ref,p(idx).symmetry);

% Apply laplacian
if sg_check_param(p(idx),'apply_laplacian')
    v.ft_ref = del2(v.ft_ref);
end

% Calculate transform
v.ft_ref = fftn(v.ft_ref);




    
