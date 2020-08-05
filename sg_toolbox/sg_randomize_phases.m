function r_ft = sg_randomize_phases(ft,fourier_cutoff)
%% sg_randomize_vol_phases
% Generate a noise volume by randomizing the phases of an input Fourier 
% transform. Phases are randomized beyond a given fourier cutoff. 
%
% This is essentially the phase-randomization process used for computing
% mask-corrected FSCs.
%
% WW 04-2019


%% Randomize phases

% Split phases and amplitudes
amp = abs(ft);
phases = angle(ft);

% Calculate pixel distance array
R = sg_distancearray(ft,1);

% Determine for phase randomization
pr_sub = ifftshift(R > fourier_cutoff);
pr_idx = find(pr_sub);
n_pr = size(pr_idx,1);

% Randomize phases
rand_phase = phases;
rand_phase(pr_idx) = phases(pr_idx(randperm(n_pr)));
rand_phase = reshape(rand_phase,size(ft));

% Reassemble spectrum
r_ft = amp.*exp(1i.*rand_phase);


        


