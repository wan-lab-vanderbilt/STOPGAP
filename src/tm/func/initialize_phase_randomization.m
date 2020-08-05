function o = initialize_phase_randomization(p,o,s,idx)
%% randomize_phases_under_bpf
% Generate noise volumes by randomizing the phases under the areas passed
% through by the bandpass filter.
%
% WW 09-2018

%% Check check


% Check for override setting
if sg_check_param(p(idx),'noise_corr')
    o.noise_corr = p(idx).noise_corr;    
else 
    o.noise_corr = false;
end

% Return if no noise-correlation needed
if ~o.noise_corr
    return
end

    
%% Get random seed

% Read seed
o.seed_idx = idx;
o = read_random_seed(p,o,s,idx);


%% Randomize phases for each map
disp([s.nn,'Initialize parameters for phase-randomization...']);


% Find pass-through indices
o.pt_idx = find(o.tmpl_bpf);
o.n_pt_pix = numel(o.pt_idx);

% Initialize cell for each template
o.pr_tmpl = cell(o.n_tmpl,1);

% Calculate phase-randomized volues
disp([s.nn,'Generating phase-randomized volumes...']);
for i = 1:o.n_tmpl
    
    % Split amplitudes and phases
    ft = fftn(o.tmpl{i});
    amp = abs(ft(o.pt_idx));
    phase = exp(1i.*angle(ft(o.pt_idx)));
    clear ft
            
    % Initialize cell
    o.pr_tmpl{i} = cell(o.noise_corr,1);
    
    for j = 1:o.noise_corr
        
        % Generate randomized indices
        rng(round(o.rseed/(i*j)),'twister');    
        r_idx = o.pt_idx(randperm(o.n_pt_pix));

        % Generate randomized map
        ftTmpl = zeros(o.tmpl_size,o.tmpl_size,o.tmpl_size,'single');
        ftTmpl(r_idx) = amp.*phase;
        o.pr_tmpl{i}{j} = real(ifftn(ftTmpl));
   
    end
end
        
        


