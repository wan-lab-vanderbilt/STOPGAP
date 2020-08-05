function watch_for_files(p,o,s,idx,filename,n_files,msg)
%% watch_for_files
% Watch for a number of files to be written. 
%
% Progress files are written by each node into the commdir; the number of 
% lines indicates the progress of the job.
%
% WW 06-2019

%% Wait!!!

% Initialize counters
n_complete = 0;
n_back = 0;

% Wait for files
while n_complete < n_files
    pause(s.wait_time);
    
    % Count files
    n_complete = numel(dir([p(idx).rootdir,'/',o.commdir,'/',filename,'_*']));
    
    % Display progress
    status = [num2str(n_complete),' out of ',num2str(n_files),msg];
    n_back = print_status(status, n_back);
    
end
