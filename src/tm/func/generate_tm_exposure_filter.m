function f = generate_tm_exposure_filter(o,f)
%% generate_tm_exposure_filter
% A function for generating a per-slice dose filter for template matching. 
%
% If the wedgelist contains a field 'crit_exp_param', external parameters
% oare used. Otherwise, the parameters from Grant and Grigorieff (2015). 
%
% WW 01-2010

%% Set critical exposure parameters

if isfield(o.wedgelist,'crit_exp_param')    
    a = o.wedgelist(f.wedge_idx).crit_exp_param(1);
    b = o.wedgelist(f.wedge_idx).crit_exp_param(2);
    c = o.wedgelist(f.wedge_idx).crit_exp_param(3);    
else
    a = 0.245;
    b = -1.665;
    c = 2.81;
end


%% Calculate filter per slices

% Initialize dose filter
exp_filt = zeros([o.tmpl_size,o.tmpl_size,o.tmpl_size]);

% Number of slices
n_slices = numel(f.slice_idx);

% Loop through and calculate filter per slice
for i = 1:n_slices

    % Parse frequencies at slice indices
    temp_freq = f.freq_array(f.slice_idx{i});
    
    % Calculate exposure-dependent amplitude attenuator
    exp_filt(f.slice_idx{i}) = exp_filt(f.slice_idx{i}) + exp((-o.wedgelist(f.wedge_idx).exposure(i))./(2.*((a.*(temp_freq.^b))+c)));

end

% Reweight filter
f.exp_filt = exp_filt.*f.slice_weight;


    
