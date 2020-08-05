function cc_map = calculate_flcf(mref,mask,conjTarget,conjTarget2)
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
boxsize = size(mref);
n_pix = sum(mask(:));

% Calculate inital Fourier transfroms
mref = fftn(mref);
mask = fftn(mask);

% Calculate numerator of equation
numerator = real(ifftn(mref.*conjTarget));
clear mref

% Calculate denominator in three steps
sigma_a = real(ifftn(mask.*conjTarget2)./n_pix);       % First part of denominator sigma
sigma_b = real(ifftn(mask.*conjTarget)./n_pix).^2;     % Second part of denominator sigma
denominator = n_pix.*sqrt(sigma_a-sigma_b);
clear sigma_a sigma_b

% Shifted FLCL map
cc_map = real(numerator./denominator);
clear numerator denominator

% Calculate map and do a much of flips to get orientation correct...
cen = floor(boxsize./2)+1;
cc_map = flip(flip(flip(cc_map,1),2),3);
cc_map = circshift(cc_map,cen);


