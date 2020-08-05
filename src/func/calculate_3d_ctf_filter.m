function f = calculate_3d_ctf_filter(o,f,mode)
%% calculate_3d_ctf_filter
% Take input 1D CTF functions and calculate a 3D CTF function by linear
% interpolation.
%
% WW 08-2018

%% Check for supersampling

% Check for super sampling
if sg_check_param(o,'avg_ss')
    ss = o.avg_ss > 1;
else
    ss = false;
end


if strcmp(mode,'avg') && ss
    boxsize = o.ss_boxsize;
else
    boxsize = o.boxsize;
end


%% Calculate filter!!!

% Number of angles
n_ang = numel(f.slice_idx);

% Intialize filter
ctf_filt = zeros(boxsize,'single');

% Interpolate filter
for i = 1:n_ang
    
    % Interpolate filter
    F = griddedInterpolant(f.freq_1d_crop,f.crop_ctf(i,:),'cubic','none');
    interp = F(f.freq_array(f.slice_idx{i}));
    
    % Add to filter
    ctf_filt(f.slice_idx{i}) = ctf_filt(f.slice_idx{i}) + interp;
    
end

% Reweight filter
ctf_filt(isnan(ctf_filt)) = 0;
f.ctf_filt = ctf_filt.*f.wedge_weight;




