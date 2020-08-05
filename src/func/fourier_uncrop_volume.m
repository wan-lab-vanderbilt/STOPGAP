function  vol = fourier_uncrop_volume(crop_vol,f_idx,bpf)
%% fourier_uncrop_volume
% Use Fourier-cropping indices to rescale a Fourier cropped volume back to
% the original size.
%
% WW 08-2018

if nargin == 2
    bpf = ones(size(crop_vol),'single');
end

%% Uncrop it!

% Determine final shape
final_shape = size(f_idx);

% Calculate scaling factor
scaling = prod(final_shape./size(crop_vol));

% Fourier transform
ft_vol = zeros(final_shape,'like',crop_vol);
ft_vol(f_idx) = fftn(crop_vol).*scaling.*bpf;

% Crop and reshape
vol = real(ifftn(reshape(ft_vol,final_shape)));













