function o = tps_initialize_masks(p,o,s,idx)
%% tps_initialize_masks
% Initialize a volume array to store volumes for calculating tube power
% spectra.
% 
% WW 10-2022


%% Read mask
disp([s.cn,'Loading mask...']);

% Parse mask name
o.mask_name = [o.maskdir,p(idx).mask_name];

% Check for local copy
if o.copy_local
    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','mask_copied',s.wait_time,o.mask_name,false,s.copy_function);
end


% Read and store mask
o.mask = sg_volume_read([o.rootdir,o.mask_name]);



%% Initialize BPF
disp([s.cn,'Calculating bandpass filter...']);

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









