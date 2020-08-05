function pairs = intialize_pairlist(o,s)
%% intialize_pairlist'
% Read in pairlist for CC-matrix calculation and distribute pairs to
% parallel computing jobs.
%
% WW 06-2019

%% Initialize pairs
disp([s.nn,'Initializing pair lists...']);

% Calculate pairlist
pairlist = sg_pca_determine_unique_pairs(o.n_subtomos);
n_pairs = size(pairlist,1);

% Determine pairs to calculate
[p_start, p_end, ~] = job_start_end(n_pairs, o.n_cores, o.procnum);
pairs = pairlist(p_start:p_end,:);




