function o = initialize_fourier_crop_alignment(s,o)
%% initialize_fourier_crop_alignment
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
% WW 08-2018

%% Check check

% Check if Fourier cropping is disabled
if ~sg_check_param(s,'fourier_crop')
    o.fcrop = false;
    if isfield(o,'f_idx')
        o = rmfield(o,'f_idx');
    end
    return
end


% Determine cropped boxsize
[crop_dims,fcrop] = determine_fcrop_size_from_bpf(o.bpf);
if ~fcrop
    warning([s.nn,'ACHTUNG!!! 3/2 Fourier pixels beyond the low pass filter is beyond the box edge. Fourier cropping will not be used.']);
    o.fcrop = false;
    return
else
    o.fcrop = true;
end



%% Initialize Fourier cropping arrays
disp([s.nn,'Initializing indices for a Fourier cropped alignment run...']);


% Replace boxsizes
o.full_boxsize = o.boxsize;
o.full_cen = o.cen;
o.boxsize = crop_dims;  % Set pixelsize to 3/2 Nyquist
o.fcrop_boxsize = o.boxsize;
o.cen = floor(o.boxsize/2)+1;

% Calculate cropping indices
o.f_idx = fcrop_calculate_3d_idx(o.full_boxsize,o.boxsize);

% Crop bandpass
if size(o.bpf,1) ~= o.boxsize
    o.full_bpf = o.bpf;
    o.bpf = fcrop_fftshifted_vol(o.full_bpf,o.f_idx);
end


% 
% %% Rescale volumes using linear interpolation
% 
% % Volumes to rescale
% rsres_vol = {'mask','mask2'};
% 
% % Rescale volumes
% for i = 1:numel(rsres_vol)
%     if isfield(o,rsres_vol{i})
%         if size(o.(rsres_vol{i}),1) ~= o.boxsize
%             temp_vol = sg_rescale_volume_realspace(o.(rsres_vol{i}),o.boxsize,'linear');
%             o.(rsres_vol{i}) = temp_vol;
%         end
%     end
% end
% 
% 
% %% Rescale references using Fourier cropping
% 
% % Loop through each class
% for i = 1:o.n_classes
%     for j = 1:2
%         if size(o.ref.(char(64+j)){i},1)
%             temp = fourier_crop_volume(o.ref.(char(64+j)){i},o.f_idx);
%             o.ref.(char(64+j)){i} = temp;
%         end
%     end
% end

    















