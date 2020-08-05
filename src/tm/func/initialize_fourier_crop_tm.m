function o = initialize_fourier_crop_tm(o,s)
%% initialize_fourier_crop_tm
% Initialize volume arrays required for performing Fourier cropped
% alignment; in this mode, all volumes are scaled so that low pass filter 
% Nyquist is 2/3 the pixelsize. This can substantially reduce computational
% time by lowering the number of voxels used, but results in slightly
% poorer real-space correlations caused by poorer interpolation. This can
% be offset by using tricubic interpolation, but with more computational
% cost. 
%
% References are rescaled using Fourier cropping, as this precisely
% preserves the Fourier information. Masks are rescaled using linear 
% interpolation as this properly preserves the masking properties; Fourier
% cropping can produce ripples in regions of unity. 
%
% WW 01-2019



%% Check check

% Return for no Fourier cropping
if ~sg_check_param(s,'fourier_crop')
    o.fcrop = false;
    return
end

% Return if templates were not reloaded
if ~o.reload_tmpl
    return
end



%% Initialize Fourier cropping arrays
disp([s.nn,'Initializing indices for a Fourier cropped template matching...']);

% Calcluate crop size for template filter
[crop_tmpl_size, tmpl_fcrop] = determine_fcrop_size_from_bpf(o.tmpl_bpf);
if tmpl_fcrop
    o.full_tmpl_size = o.tmpl_size;
    o.full_tmpl_cen = o.tmpl_cen;
    o.tmpl_size = max(crop_tmpl_size);
    o.tmpl_cen = floor(o.tmpl_size/2)+1;
    o.fcrop = true;
else
    warning([s.nn,'ACHTUNG!!! 3/2 Fourier pixels beyond the low pass filter is beyond the box edge. Fourier cropping will not be used.']);
    o.fcrop = false;
    return
end


% Calcluate crop size for tile filter
if tmpl_fcrop
    [crop_tilesize, ~] = determine_fcrop_size_from_bpf(o.tile_bpf);
    o.full_tilesize = o.tilesize;
    o.full_tile_cen = o.tile_cen;
    o.tilesize = crop_tilesize;
    o.tile_cen = floor(o.tilesize./2)+1;
end



% Calculate cropping indices
o.f_idx_tmpl = calculate_3d_fcrop_idx(o.full_tmpl_size,o.tmpl_size);
o.f_idx_tile = calculate_3d_fcrop_idx(o.full_tilesize,o.tilesize);

% Crop bandpass filters
if size(o.tmpl_bpf,1) ~= o.tmpl_size
    o.full_tmpl_bpf = o.tmpl_bpf;
    o.tmpl_bpf = crop_fftshifted_vol(o.full_tmpl_bpf,o.f_idx_tmpl);
end
if size(o.tile_bpf,1) ~= o.tilesize
    o.full_tile_bpf = o.tile_bpf;
    o.tile_bpf = crop_fftshifted_vol(o.full_tile_bpf,o.f_idx_tile);
end

%% Rescale volumes using linear interpolation

% Rescale masks
for i = 1:o.n_tmpl
    temp_vol = sg_rescale_volume_realspace(o.mask{i},o.tmpl_size,'linear');
    o.mask{i} = temp_vol;
end



%% Rescale templates using Fourier cropping

% Rescale templates
for i = 1:o.n_tmpl
    tmpl = fourier_crop_volume(o.tmpl{i},o.f_idx_tmpl);
    o.tmpl{i} = tmpl;
end


    





















