function f = generate_exposure_filter_slices(o,f,mode)
%% generate_exposure_filter_slices
% A function for generating a per-slice dose filter. 
%
% If the wedgelist contains a field 'crit_exp_param', external parameters
% oare used. Otherwise, the parameters from Grant and Grigorieff (2015). 
%
% WW 01-2018

%% Initialize

% Parse wedge index
w = f.wedge_idx;

%% Set critical exposure parameters

if isfield(o.wedgelist,'crit_exp_param')    
    a = o.wedgelist(w).crit_exp_param(1);
    b = o.wedgelist(w).crit_exp_param(2);
    c = o.wedgelist(w).crit_exp_param(3);    
else
    a = 0.245;
    b = -1.665;
    c = 2.81;
end


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


%% Calculate filter per slices

% Initialize dose filter
exp_filt = zeros(boxsize,'single');

% Number of slices
n_slices = numel(f.slice_idx);

% Loop through and calculate filter per slice
for i = 1:n_slices

    % Parse frequencies at slice indices
    temp_freq = f.freq_array(f.slice_idx{i});
    
    % Calculate exposure-dependent amplitude attenuator
    exp_filt(f.slice_idx{i}) = exp_filt(f.slice_idx{i}) + exp((-o.wedgelist(w).exposure(i))./(2.*((a.*(temp_freq.^b))+c)));

end

% Reweight filter
f.exp_filt = exp_filt.*f.wedge_weight;


    