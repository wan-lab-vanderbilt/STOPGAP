function f = generate_pca_bpf(o,s)
%% generate_pca_bpf
% Generate a set of bandpass filters from the filter list.
%
% WW 06-2019

%% Generate filters
disp([s.nn,'Generating bandpass filters...']);

% Initialize struct
f = struct();

% Generate filters
for i = 1:o.n_filt
    
    % Generate filter
    f.(['bpf_',num2str(i)]) = calculate_3d_bandpass_filter(o.boxsize,o.filtlist(i).lp_rad,o.filtlist(i).lp_sigma,o.filtlist(i).hp_rad,o.filtlist(i).hp_sigma);
    
end



