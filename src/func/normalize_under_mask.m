function [ref,n_pix,m_idx] = normalize_under_mask(ref, mask)
%% normalize_under_mask
% A function to take a reference volume and a mask, and normalize the area
% under the mask to 0-mean and standard deviation of 1. 
%
% WW 06-2019


%% Normalize reference!!!

% Calculate mask parameteres
m_idx = mask > 0;
n_pix = sum(mask(:));   % Pixels under mask

% Calcualte stats
m = mean(ref(m_idx));
s = std(ref(m_idx));

% Normalize reference
ref = ref - m;
ref = ref./s;
ref = ref.*mask;


