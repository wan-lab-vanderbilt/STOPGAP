function n_p_cores = determine_n_p_avg_cores(n_motl,n_cores)
%% determine_n_p_avg_cores
% Determine a roughly optimal number of cores for parallel averaging.
%
% WW 06-2019

%% Determine n_cores

% Square root of n_motl
root_motl = round(sqrt(n_motl));

% Calcualte number of parallel cores
if root_motl > n_cores
    n_p_cores = n_cores;
% elseif root_motl < (n_cores/2);
%     n_p_cores = n_cores/2;
else
    n_p_cores = root_motl;
end


