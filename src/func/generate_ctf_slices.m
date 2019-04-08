function f = generate_ctf_slices(o,f,defocii)
%% generate_ctf_silces
% A function for generating CTF filters for each slice of a tomogram. 
%
% WW 01-2018

%% Initialize

% Number of slices
n_tilts = numel(defocii);

% Defocus filter
ctf_filt = zeros(o.boxsize,o.boxsize,o.boxsize);

% Parse wedge index
w = f.wedge_idx;

% Parse phaseshifts
if isfield(o.wedgelist,'pshiftdeg')
    pshiftdeg = o.wedgelist(w).pshiftdeg;
else
    pshiftdeg = zeros(n_tilts,1);
end

%% Calculate CTFs

for i = 1:n_tilts
    
    % Parse frequency values
    temp_freq = f.freq_array(f.slice_idx{i});
    
    % Calculate CTF values at frequency points
    ctf_values = calculate_ctf(defocii(i), pshiftdeg(i),o.wedgelist(w).famp, o.wedgelist(w).cs, o.wedgelist(w).evk, temp_freq);
    
    % Store CTF values
    ctf_filt(f.slice_idx{i}) = ctf_filt(f.slice_idx{i}) + abs(ctf_values);
    
end

f.ctf_filt = ctf_filt.*f.slice_weight;
    


