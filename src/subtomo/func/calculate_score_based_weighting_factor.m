function weighting_factor = calculate_score_based_weighting_factor(pixelsize,attenuation,min_score,max_score)
%% calculate_score_based_weighting_factor
% Calculate a weighting factor for score-based weighting for subtomogram
% averages. The weighting factor is calculated such that the, for the 
% lowest scoring subtomogram, the B-factor at Nyquist equals the 
% attenuation value.
%
% WW 08-2018

%% Calculate factor

% Score range
d_score = max_score - min_score;

% Nyquist resolution
nyquist = pixelsize*2;
g = 1/nyquist;

% Weighting factor
n = log(attenuation);
d = d_score*(g^2);
weighting_factor = n/d;

