function crop_vol = crop_fftshifted_vol(vol,f_idx)
%% crop_fshifted_vol
% Crop an volume that is in Fourier space and also fftshifted using input
% Fourier indices.
%
% WW 08-2018

%% Crop!!!

% Determine final shape
final_shape = [sum(f_idx(:,1,1)),sum(f_idx(1,:,1)),sum(f_idx(1,1,:))];

% Crop array
crop_vol = reshape(vol(f_idx),final_shape);


