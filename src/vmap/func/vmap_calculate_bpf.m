function o = vmap_calculate_bpf(p,o,s,idx)
%% vmap_calculate_bpf
% Calculate a bandpass fitler and save it to the 'o' struct.
%
% WW 06-2019

%% 

%% Assign default values

if sg_check_param(p(idx),'lp_sigma')
    lp_sigma = p(idx).lp_sigma;
else
    lp_sigma = 2;
end

if sg_check_param(p(idx),'hp_rad')
    hp_rad = p(idx).hp_rad;
else
    hp_rad = 0;
end

if sg_check_param(p(idx),'hp_sigma')
    hp_sigma = p(idx).hp_sigma;
else
    hp_sigma = 0;
end

%% Generate filter

    
disp([s.nn,'Caculating bandpass filter...']);


% Generate filter
lowpass = sg_sphere(o.boxsize,p(idx).lp_rad,lp_sigma);
hipass = sg_sphere(o.boxsize,hp_rad,hp_sigma);
o.bandpass = ifftshift(lowpass-hipass); % Bandpass filter



    