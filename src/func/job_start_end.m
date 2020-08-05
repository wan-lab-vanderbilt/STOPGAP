function [job_start, job_end, job_array] = job_start_end(n_jobs, n_cores, procnum)
%% job_start_end
% Given a set of job parameters, the job script will determine the
% optimally spaced number of jobs and return the start and end number for a
% particular node. 
%
%WW 07-2017

%% Determine job parameters

% Average job size per node
avg_size = floor(n_jobs/n_cores);

% Array to hold job sizes, starts, and ends
job_array = zeros(n_cores,3);
job_array(:,1) = ones(n_cores,1)*avg_size;

% Disperse remainder to earliest nodes
remainder = mod(n_jobs,n_cores);
job_array(1:remainder,1) = job_array(1:remainder,1) + 1;

% Fill ends
job_array(:,3) = cumsum(job_array(:,1));

% Fill starts
job_array(1,2) = 1;
job_array(2:end,2) = job_array(2:end,3) - job_array(2:end,1) + 1;

if nargin == 3
    % Return values
    job_start = job_array(procnum,2);
    job_end = job_array(procnum,3);
else
    job_start = [];
    job_end = [];
end






