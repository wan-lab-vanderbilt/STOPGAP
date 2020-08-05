function o = distribute_filter_jobs(o)
%% distribute_filter_jobs
% Evenly distribute a set of jobs across a set of cores.
%
% WW 06-2019

%% Distribute jobs

if  (o.n_cores/o.n_filt) >= 1

    % Array for distributing jobs
    array = false(ceil(o.n_cores/o.n_filt),o.n_filt);
    array(1,:) = true;

    % Core array
    all_cores = 1:o.n_cores;

    % Assigned cores
    cores = all_cores(array(1:o.n_cores));
    
    % Check for job
    if any(cores==o.procnum)
        o.filt_job_core = true;
        o.filt_jobs = find(cores == o.procnum);
    else
        o.filt_job_core = false;
    end
    
    
else
    
    % Determine jobs per core
    [job_start,job_end,~] = job_start_end(o.n_filt,o.n_cores,o.procnum);
    
    % Assign jobs
    o.filt_job_core = true;
    o.filt_jobs = job_start:job_end;
    
end


    




