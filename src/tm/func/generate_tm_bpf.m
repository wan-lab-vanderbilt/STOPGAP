function o = generate_tm_bpf(p,o,s,idx)
%% generate_tm_bpf
% A function to generate bandpass filters for tempalte matching. Parameters
% are taken from the 'p' struct, and filter is stored in the 'o' struct. 
% 
% The first 1D bandpass filter is generated with respect to the template
% size. The 3D bandpass filteres are interpolated from the 1D filter.
%
% WW 01-2019

%% Check check

% Return if templates were not reloaded
if ~o.reload_tmpl
    return
end

%% Assign default values

if sg_check_param(p(idx),'lp_sigma')
    lp_sigma = p(idx).lp_sigma;
else
    lp_sigma = 3;
end

if sg_check_param(p(idx),'lp_sigma')
    hp_sigma = p(idx).hp_sigma;
else
    hp_sigma = 2;
end

% Assign boxsizes
o.tmpl_cen = floor(o.tmpl_size/2)+1;
o.tile_cen = floor(o.tilesize/2)+1;


%% Generate filter
disp([s.nn,'Caculating bandpass filters...']);

% Calcualte 1D bandpass filter
radius = ceil(o.tmpl_size/2);
o.r_1d = (0:radius)./radius;    % Radius of bpf as fraction Nyquist
o.bpf_1d = sg_bandpass_filter_1d(radius,p(idx).lp_rad,lp_sigma,p(idx).hp_rad,hp_sigma);


% Generate filter for template
o.r_tmpl = sg_frequencyarray(o.tmpl{1},0.5);    % Radial array as fraction Nyquist
tmpl_bpf = interp1(o.r_1d,o.bpf_1d,o.r_tmpl,'pchip',0);    % Generate template bpf by interpolation
o.tmpl_bpf = ifftshift(tmpl_bpf); % Bandpass filter


% Generate filter for tile
o.r_tile = sg_frequencyarray(zeros(o.tilesize),0.5);    % Radial array as fraction Nyquist
tile_bpf = interp1(o.r_1d,o.bpf_1d,o.r_tile,'pchip',0);    % Generate tile bpf by interpolation
o.tile_bpf = ifftshift(tile_bpf); % Bandpass filter

    
    
        
