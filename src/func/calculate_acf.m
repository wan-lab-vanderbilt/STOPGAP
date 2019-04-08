function acf = calculate_acf(vol)
%% calculate_acf
% A function to return the autocorrelcation function of a 3D volume. 
%
% The ACF is rescaled such that the central pixel equals 1.
%
% WW 02-2018


%% Calculate autocorrelation

% Calculate Fourier transform
ft = fftn(vol);

% Calculate correlation
corr = ft.*conj(ft);

% Inverse transform
acf = real(ifftn(corr));

% Central pixel value
cen_val = acf(1);

% Shift and rescale acf
acf = ifftshift(acf)./cen_val;

