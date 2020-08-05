function f_idx = calculate_1d_crop_idx(full_size,crop_size)
%% calculate_1d_crop_idx
% Calcualte a the 1D indices for Fourier cropping an array.
%
% WW 08-2018

%% Caclualte indices

f_idx = false(1,full_size);
f_idx(1:crop_size) = true;
f_idx = circshift(f_idx,[0,-floor(crop_size/2)]);
