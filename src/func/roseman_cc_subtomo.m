function cc_map = roseman_cc_subtomo(rotRef, rotMask, conjSubtomo,conjSubtomo2)
%% roseman_cc_subtomo
% A function for calculating the "fast local correlation algorithm" (FLCL)
% from Roseman, Ultramicroscopy 2003; (doi: 10.1016/S0304-3991(02)00333-9).
% 
% The script used dynamo_roseman_local.m as a template. The variables in 
% this script attempt to take their names from the Roseman paper. 
%
% This function is implemented for subtomo averaging, and therefore assumes
% idential dimensions between reference and subtomo, rather than as a
% localization function. 
%
% If the mask is not binarized, the value of the mask acts as a weighting
% function. 
%
% Inputs:
% rotRef: rotated referene
% rotMask: rotated mask 
% conjSubtomo: complex conjugate of the FT of the subtomo
% conjSubtomo2: complex conjugate of the FT of the squared subtomo
%
% Note: any filtering i.e. wedgemask, bandpass fitlers, should be done
% prior to this function. 
%
% WW 02-2018


%% Process mask and reference

% Calculate mask parameteres
mask_idx = rotMask > 0;
P = sum(rotMask(:));   % Pixels under mask
boxsize = size(rotMask,1);

% Mask and normalize reference
mRef = rotRef.*rotMask;
mRef(mask_idx) = mRef(mask_idx)-mean(mRef(mask_idx));

% Normalization factor of references
sigmaRef = sqrt(sum(mRef(mask_idx).^2)); % StDev of area under mask

%% Calculate numerator (of eq 5 in paper)

% Fourier transform of masked ref
ftRef = fftn(mRef);

% Convolution of masked reference and subtomo
numerator = real(ifftn(ftRef.*conjSubtomo));

%% Calculate demoninator

% Fourier transform of mask
ftMask = fftn(double(rotMask));

% Mean of subtomo under mask
mean_subtomo = real(ifftn(ftMask.*conjSubtomo));

% Mean intensity of subtomo under mask 
intens_subtomo = real(ifftn(ftMask.*conjSubtomo2)); % Technically should be ft of mask^2, but doesn't matter for binary mask

% Calculate denominator (of eq 5 in paper)
denominator = real(sqrt(intens_subtomo - ((mean_subtomo.^2)./P)).*sigmaRef);

% Clear zeros from denominator
denominator(denominator == 0) = -1;


%% Calculate CC map

% Calculate map and do a much of flips to get orientation correct...
cc_map = fftshift(numerator./denominator);
cc_map = flip(cc_map,1);
cc_map = flip(cc_map,2);
cc_map = flip(cc_map,3);
cc_map = circshift(cc_map,[boxsize+1,boxsize+1,boxsize+1]);




