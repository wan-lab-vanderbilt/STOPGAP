function o = initialize_motl_for_subtomo_alignment(p,o,s,idx)
%% initialize_motl_for_subtomo_alignment
% Read run settings and determine motls for subtomogram alignment.
%
% WW 08-2018


%% Check for restart


%% Determine motls for alignment

% Check for subset processing
subset = false;
if sg_check_param(p(idx),'subset')
    if p(idx).subset < 100
        subset = true;
    end
end


% Calculate parameters
if subset        
    % Calculate job parameters
    [start_idx, end_idx] = job_start_end(o.n_rand_motls, o.n_cores, o.procnum);
    % Parse subtomogram numbers
    o.ali_motl = o.rand_motl(start_idx:end_idx);
else
    % Calculate job parameters
    [start_idx, end_idx] = job_start_end(o.n_motls, o.n_cores, o.procnum);
    % Parse subtomogram numbers
    o.ali_motl = o.motl_idx(start_idx:end_idx);
end


% Number of entries to align
o.n_ali_motls = end_idx - start_idx + 1;    

% Force shape
o.ali_motl = reshape(o.ali_motl,1,o.n_ali_motls);

disp([s.nn,'Determining parameters for parallel alignment... ',num2str(o.n_ali_motls),' subtomograms to be aligned...']);
