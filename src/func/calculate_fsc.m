function [corr_fsc,fsc,mean_rfsc] = calculate_fsc(ref_A,ref_B,mask,symmetry,fourier_cutoff,n_repeats)
%% calculate_fsc
% Calcualte a phase-randomized FSC between two volumes. This can be
% repeated in order to minimize noise from the phase-randomization.
%
% WW 06-2019


%% Prepare references

% Symmetrize
ref = cell(2,1);
ref{1} = sg_symmetrize_volume(ref_A,symmetry);
ref{2} = sg_symmetrize_volume(ref_B,symmetry);


%% Prepare arrays

% Calculate pixel distance array
R = ifftshift(sg_distancearray(ref{1},1));

% Number of Fourier Shells
n_shells = floor(size(ref_A,1))/2;  % Hardcoded to half the box-size

% Precalculate shell masks
shell_mask = cell(n_shells,1);
for i = 1:n_shells
    % Shells are set to one pixel size
    shell_start = (i-1);
    shell_end = i;
    
    % Generate shell mask
    temp_mask = (R >= shell_start) & (R < shell_end);
    
    % Write out linearized shell mask
    shell_mask{i} = temp_mask(:);
end


%% Phase-randomized FSC


% Intialize randomized FSC array
rfsc = zeros(n_repeats,n_shells);

% Determine for phase randomization
pr_idx = find((R > fourier_cutoff));
n_pr = size(pr_idx,1);

% Calculate unmasked phases and amplitudes
phase = cell(2,1);
amp = cell(2,1);
for i = 1:2
    % Calculate transform
    ft = fftn(ref{i});
    
    % Store amplitudes
    amp{i} = abs(ft);
    
    % Temporary phase
    phase{i} = exp(1i.*angle(ft));
end
clear ft

% Calculate phase-randomized fSC
for j = 1:n_repeats
    
    % Phase randomized FTs
    rft = cell(2,1);    
    intensity = cell(2,1);
    
    % Generate phase-randomized FTs
    for i = 1:2
        
        % Randomize phases
        rphase = phase{i};
        rphase(pr_idx) = phase{i}(pr_idx(randperm(n_pr)));

        
        % Reassemble and apply mask
        rft{i} = real(ifftn(amp{i}.*rphase));
        rft{i} = fftn(rft{i}.*mask);
        
        % Compute intensity
        intensity{i} = rft{i}.*conj(rft{i});
        clear rphase
        
    end
    AB_cc = rft{1}.*conj(rft{2});
    clear rft
        
    % Initialize hell arrays
    AB_cc_array = zeros(1,n_shells); % Complex conjugate of A and B
    intA_array = zeros(1,n_shells); % Intenisty of A
    intB_array = zeros(1,n_shells); % Intenisty of B
    
    % Sum Fourier shells
    for i = 1:n_shells    
        AB_cc_array(i) = sum(AB_cc(shell_mask{i}));
        intA_array(i) = sum(intensity{1}(shell_mask{i}));
        intB_array(i) = sum(intensity{2}(shell_mask{i}));
    end
    clear intesnity AB_cc
        
    % Calcualte randomized FSC
    rfsc(j,:) = real(AB_cc_array./sqrt(intA_array.*intB_array));
    clear AB_cc_array intA_array intB_array
    
end
mean_rfsc = mean(rfsc,1);


%% Calculate normal FSC

intensity = cell(2,1);
for i = 1:2
    ref{i} = fftn(ref{i}.*mask);
    intensity{i} = ref{i}.*conj(ref{i});
end
AB_cc = ref{1}.*conj(ref{2});
    

% Initialize hell arrays
AB_cc_array = zeros(1,n_shells); % Complex conjugate of A and B
intA_array = zeros(1,n_shells); % Intenisty of A
intB_array = zeros(1,n_shells); % Intenisty of B

% Sum Fourier shells
for i = 1:n_shells    
    AB_cc_array(i) = sum(AB_cc(shell_mask{i}));
    intA_array(i) = sum(intensity{1}(shell_mask{i}));
    intB_array(i) = sum(intensity{2}(shell_mask{i}));
end
clear AB_cc intensity ref

% Normal FSC
fsc = real(AB_cc_array./sqrt(intA_array.*intB_array));

% Corrected FSC
corr_fsc = mean(((repmat(fsc,[n_repeats,1])-rfsc)./(1-rfsc)),1);
corr_fsc(1:fourier_cutoff-1) = fsc(1:fourier_cutoff-1);




