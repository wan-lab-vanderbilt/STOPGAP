function crop_vol = fourier_crop_volume(input_vol,f_idx,threshold)
%% fourier_crop_volume
% Fourier crop a volume using the given Fourier cropping indices.
%
% WW 08-2018

%% Crop it!

% Determine final shape
final_shape = [sum(f_idx(:,1,1)),sum(f_idx(1,:,1)),sum(f_idx(1,1,:))];

% Calculate scaling factor
scaling = prod(final_shape./size(input_vol));

% Fourier transform
ft_vol = fftn(input_vol).*scaling;

% Crop and reshape
crop_vol = real(ifftn(reshape(ft_vol(f_idx),final_shape)));

% Apply optional threshold
if nargin == 3
    idx = crop_vol<threshold;
    crop_vol(idx) = 0;
end




