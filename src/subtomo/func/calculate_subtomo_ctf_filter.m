function f = calculate_subtomo_ctf_filter(p,o,s,f,idx,motl,new_tomo,mode)
%% calculate_subtomo_ctf_filter
% Calculate a local 3D CTF-filter.
%
% WW 08-2018


%% Caculate local filter!

% Calculate center of mass at each tilt
if new_tomo
    f = calculate_tilt_center_of_mass(p,o,f,idx);
end

% Calculate local defocii
defocii = calculate_local_defocii(p,o,idx,f,motl);

% Calculate 1D CTF arrays
f = calculate_scaled_1d_ctf(o,f,defocii,mode);

% Calculate 3D CTF filter
f = calculate_3d_ctf_filter(o,f,mode);

