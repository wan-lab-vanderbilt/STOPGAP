function [mref,n_pix,m_idx] = sg_normalize_under_mask(ref, mask)
%% sg_normalize_under_mask
% A function to take a reference volume and a mask, and normalize the area
% under the mask to 0-mean and standard deviation of 1. 
%
% WW 02-2018


%% Normalize reference!!!

% Calculate mask parameteres
m_idx = mask > 0;
n_pix = sum(mask(:));   % Pixels under mask

% Mask and set mea to zero
mref = ref.*mask;
mref(m_idx) = mref(m_idx)-(sum(mref(m_idx))./n_pix);

% Normalization factor of references
sigmaRef = sqrt(sum(mref(m_idx).^2)./n_pix); % StDev of area under mask
mref = mref./sigmaRef;

