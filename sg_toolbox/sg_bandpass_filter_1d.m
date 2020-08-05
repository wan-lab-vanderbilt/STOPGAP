function bpf = sg_bandpass_filter_1d(radius,lp_rad,lp_sigma,hp_rad,hp_sigma)
%% sg_bandpass_filter_1d
% Calculate a 1-dimensional bandpass filter.
%
% WW 03-2018


%% Calculate bandpass filter

% Distance array
dist = 0:radius;

% Low pass filter
lpf = ones(size(dist));
lp_idx = dist > lp_rad;
lpf(lp_idx) = exp(-((dist(lp_idx)-lp_rad)/lp_sigma).^2);
lpf(lpf < exp(-2)) = 0;

% High pass filter
hpf = ones(size(dist));
hp_idx = dist > hp_rad;
hpf(hp_idx) = exp(-((dist(hp_idx)-hp_rad)/hp_sigma).^2);
hpf(hpf < exp(-2)) = 0;

% Bandpass filter
bpf = lpf-hpf;




