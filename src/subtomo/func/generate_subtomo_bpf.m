function o = generate_subtomo_bpf(p,o,s,idx)
%% generate_subtomo_bpf
% Generate a bandpass filter for subtomogram averaging.
%
% WW 06-2019

%% Calculate bandpass filter

disp([s.nn,'Calculating bandpass filter...']);

% Check sigmas
if isfield(p(idx),'lp_sigma')
    lp_sigma = p(idx).lp_sigma;
else
    lp_sigma = 3;
end

if isfield(p(idx),'hp_sigma')
    hp_sigma = p(idx).hp_sigma;
else
    hp_sigma = 3;
end
    
% Calculate filter
o.bpf = calculate_3d_bandpass_filter(o.boxsize,p(idx).lp_rad,lp_sigma,p(idx).hp_rad,hp_sigma);


