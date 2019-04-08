function wcc = weighted_correlation_coefficient(o,v,shift)
%% weighted_correlation_coefficient
% A function for calculating a modified version of FREALIGN's weighted
% correlation-coefficient (doi: 10.1016/j.ultramic.2004.08.008). This
% function is set up to be optimized by a minimizing function in order to
% explicitly refine shifts.
%
% WW 02-2018


%% Calculate phase shift

% Calcualte shift vectors
shift = shift./o.boxsize;

% Signal delay for shift
tau = (shift(1)*v.grid.x) + (shift(2)*v.grid.y) + (shift(3)*v.grid.z);

% Calculate phase shift
phase_shift = exp(-2*pi*1i*tau);

%% Shift reference and mask, and apply to volumes

% Shift ref and mask
shift_ref = ifftn(v.ft_ref.*phase_shift);
shift_mask = ifftn(v.ft_mask.*phase_shift);

% Apply masks and transform
ft_ref = fftn(shift_ref.*shift_mask);           % No normalization needed, as CC is evalulated per Fourier shell
ft_subtomo = fftn(v.subtomo.*shift_mask);


%% Calculate CC per shell

% Weighting constant
w = 1./sum(o.mask(:));

% Initial calculations for FSC
AB = ft_ref(v.shell_idx_all).*conj(ft_subtomo(v.shell_idx_all));     % Complex conjugate of A and B
AA =  ft_ref(v.shell_idx_all).*conj(ft_ref(v.shell_idx_all));         % Intensity of A
BB =  ft_subtomo(v.shell_idx_all).*conj(ft_subtomo(v.shell_idx_all));     % Intensity of B


% Cross correlation values per shell
fcc_array = zeros(v.n_shells,1);

% Calcualte CC per shell
for i = 1:v.n_shells
    
    % Sum shells
    temp_AB = sum(AB(v.shell_all_idx{i}));
    temp_AA = sum(AA(v.shell_all_idx{i}));
    temp_BB = sum(BB(v.shell_all_idx{i}));
    
    % Correlation coefficent
    cc = real(temp_AB/sqrt(temp_AA*temp_BB));
    
    % Filtered correlation coefficient (See Stewart and Grigorieff eq16)
    fcc = (cc^2)./(cc+w);
    fcc_array(i) = fcc;
    
end

% Calculate final CC
wcc = sum((abs(fcc_array).^3).*v.bpf_1d(v.bpf_1d_idx))./v.n_shells; % Use bandpass filter to attenuate values, and divide by n_shells to get a value between 0-1.












