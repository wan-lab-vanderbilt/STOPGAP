function filt_vol = sg_gaussian_filter_tomogram(vol,radius,sigma)
%% sg_gaussian_filter_tomogram
% Apply a gaussian filter to a tomogram. Gaussian is set by radius and
% sigma. By default, sigma is zero.
%
% Filtering is performed as a multiplication in Fourier space.
%
% WW 01-2019


%% Check check

% Check sigma
if nargin == 2
    sigma = 0;
elseif nargin ~= 3
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end



%% Generate kernel

% Volume dimensinos
dims = size(vol);

% Generate kernel
kernel = sg_sphere(dims,radius,sigma);

% Normalization factor
npix = sum(kernel(:));

%% Apply filter

% Fourier transform volume
ft_vol = fftn(vol);
clear vol

% Fourier transform kernel
ft_kernel = fftn(kernel);
clear kernel



% Filter volume
filt_vol = fftshift(real(ifftn(ft_vol.*ft_kernel)./npix));

