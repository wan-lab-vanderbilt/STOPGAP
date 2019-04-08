function scf_map = calculate_scf(mref,mask,conjTarget,conjTarget2)
%% calculate_scf
% A function to calculate a 'spectrum-correlation function', as defined 
% (doi: 10.1016/j.jsb.2006.06.001). 
%
% This function essentially correlates the FLCL against an autocorrelation
% function, which should take into account shape information.
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


%% Calculate spectrum-correlation function

% Numeric constants
boxsize = size(mask,1);
n_pix = numel(mask);

% Calculate FLCL
flcl = calculate_flcl(mref,mask,conjTarget,conjTarget2);

% Calculate ACF
acf = calculate_acf(mref);

% Normalize ACF
acf = acf-mean(acf(:));
acf = acf./std(acf(:));

% Prepare FLCL
conjFLCL = conj(fftn(flcl));
conjFLCL2 = conj(fftn(flcl.^2));

% Calculate inital Fourier transfroms
ft_acf = fftn(acf);

% Calculate numerator of equation
numerator = real(ifftn(ft_acf.*conjFLCL));

% Calculate denominator in three steps
sigma_a = real(ifftn(ft_acf.*conjFLCL2)./n_pix);       % First part of denominator sigma
sigma_b = real(ifftn(ft_acf.*conjFLCL)./n_pix).^2;     % Second part of denominator sigma
denominator = n_pix.*sqrt(sigma_a-sigma_b);

% Shifted FLCL map
scf_map = numerator./denominator;

% Calculate map and do a much of flips to get orientation correct...
scf_map = fftshift(scf_map);
scf_map = flip(scf_map,1);
scf_map = flip(scf_map,2);
scf_map = flip(scf_map,3);
scf_map = circshift(scf_map,[boxsize+1,boxsize+1,boxsize+1]);



