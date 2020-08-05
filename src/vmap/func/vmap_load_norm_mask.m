function o = vmap_load_norm_mask(p,o,s,idx)
%% vmap_load_norm_mask
% Parse parameters for normalization mask.
%
% 06-2019

      

%% Load normalization mask

% Load mask or generate default mask
if sg_check_param(p(idx),'mask_name')
    o.mask = read_vol(s,p(idx).rootdir,[o.maskdir,'/',p(idx).mask_name]);
else
    o.mask = sg_sphere(o.boxsize(1),floor(o.boxsize(1)/2)-4);
end

% Find masked voxels and values
o.m_idx = o.mask > 0;
o.m_val = o.mask(o.m_idx);

