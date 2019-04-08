function cc_map = calculate_flcl(mref,mask,conjTarget,conjTarget2)
%% calculate_flcl
% A function to calculate the "Roseman" style fast-local correlation
% function (doi:10.1016/S0304-3991(02)00333-9). The exact derivation I used
% copmes from a combination of (doi:10.1016/S0304-3991(02)00333-9) and 
% DYNAMO.
%
% Inputs are:
% mref        - masked and normalized reference; this has mean 0 and stdev
%               1 for the pixels under the mask. 
% mask        - mask applied to reference.
% conjTarget  - The complex conjugate of the Fourier transform of the
%               target.
% conjTarget2 - The complex conjugate of the Fourier transform of the
%               square of the target. 
%
% WW 02-2018

%% Calculate local correlation!

% Get numeric constants
boxsize = size(mref,1);
n_pix = sum(mask(:));

% Calculate inital Fourier transfroms
ft_ref = fftn(mref);
ft_mask = fftn(mask);

% Calculate numerator of equation
numerator = real(ifftn(ft_ref.*conjTarget));

% Calculate denominator in three steps
sigma_a = real(ifftn(ft_mask.*conjTarget2)./n_pix);       % First part of denominator sigma
sigma_b = real(ifftn(ft_mask.*conjTarget)./n_pix).^2;     % Second part of denominator sigma
denominator = n_pix.*sqrt(sigma_a-sigma_b);

% Shifted FLCL map
cc_map = numerator./denominator;

% Calculate map and do a much of flips to get orientation correct...
cc_map = fftshift(cc_map);
cc_map = flip(cc_map,1);
cc_map = flip(cc_map,2);
cc_map = flip(cc_map,3);
cc_map = circshift(cc_map,[boxsize+1,boxsize+1,boxsize+1]);


