function vol = uncrop_fftshifted_vol(crop_vol,f_idx)
%% uncrop_fshifted_vol
% Uncrop an volume that is in Fourier space and also fftshifted using input
% Fourier indices.
%
% WW 08-2018

%% Uncrop!!!


% Uncrop array
vol = zeros(size(f_idx));
vol(f_idx) = crop_vol;
