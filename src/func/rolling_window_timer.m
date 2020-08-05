function timer = rolling_window_timer(timer,task,window_size,n_jobs,n_completed)
%% rolling_window_timer
% A timer that estimates remaining time by taking the mean of a set of the
% most recent progress readings. This should give more realistic timings,
% particularly when running on a cluster with slow nodes. 
%
% The 'task' parameter can either be 'init', which initializes a new timer
% or 'time, which reads a new time reading. 
% 
% 'window_size' defines the moving window size and is only used during
% initialization.
%
% 'n_jobs' is the total number of items to be computed and 'n_completed' is
% the number of completed computations. These are only used during timing.
%
% WW 09-2018

%% Check check

switch task
    
    case 'init' 
        if (nargin < 3) || isempty(window_size)
            error('ACHTUNG!!! "window_size" is required for initialization');
        end
        
    case 'time'
        if nargin < 5
            error('ACHTUNG!!! Insufficient inputs for timing!!!');
        end
        
    otherwise
        error('ACHTUNG!!! Invalid task!!!');
end


%% Rolling window timer

switch task
    
    case 'init'
        
        % Initialize tic
        timer.t = tic;
        
        % Store window size
        timer.window_size = window_size;
        timer.rate = zeros(window_size,1);
        
        % Window counter
        timer.c = 1;
        
        % Initialize variables
        timer.rt = Inf;
        timer.units = 'hours';
        % Previous number of completed jobs
        timer.old_completed = 0;
        timer.old_time = 0;
        
        
        
    case 'time'
                
        % Calculate new time per job
        curr_time = toc(timer.t);                           % Time since initializiation
        d_time = curr_time - timer.old_time;                % Elapsed time from previous reading
        d_completed = n_completed - timer.old_completed;    % Completed jobs since last reading
        if d_completed == 0
            return
        end
        timer.rate(timer.c) = d_completed/d_time;                 % Most recent computation rate
        
        % Calculate average rate
        idx = (timer.rate > 0) & ~isinf(timer.rate);
        if isempty(idx)
            avg_rate = Inf;
        else
            avg_rate = mean(timer.rate(idx));
        end
        
        % Calcualte remaining time
        rc = n_jobs - n_completed;
        rt = rc/avg_rate;
        if rt > 3600 
            timer.rt = rt/3600;
            timer.units = 'hours';
        elseif rt > 60 
            timer.rt = rt/60;
            timer.units = 'minutes';
        else
            timer.rt = rt;
            timer.units = 'seconds';
        end
        
        % Update paramters
        timer.c = timer.c+1;
        if timer.c > timer.window_size
            timer.c = 1;
        end
        timer.old_completed = n_completed;
        timer.old_time = curr_time;
end



            


