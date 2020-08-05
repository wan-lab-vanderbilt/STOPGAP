function watch_progress(p,o,s,idx,prog_name,total_size,divide,msg,window_size)
%% watch_progress
% Watch progress files as they're being written. 
%
% Progress files are written by each node into the commdir; the number of 
% lines indicates the progress of the job.
%
% The divide parameter indicates if the progress should be divided by the
% number of cores.
%
% WW 06-2019

%% Watch it!


% Initialize counters
n_done = 0;     % Number of tasks done
n_back = 0;     % Number of lines in status

% Parse progress filename
pname = [p(idx).rootdir,'/',o.commdir,'/',prog_name,'_*'];

% Initialize timer
timer = struct();
timer = rolling_window_timer(timer,'init',window_size);


% Wait until align completion
while n_done < total_size
    
    % Wait
    pause(s.wait_time);
    
    % Check if output has started    
    if ~isempty(dir(pname))
        
        % Count all progress files
        [~,n_done_str] = system(['cat ',pname,' | wc -l']);
        n_done = str2double(n_done_str);    % Convert system output to number
        if divide
            n_done = floor(n_done./o.n_cores);
        end

        % Time estimation
        timer = rolling_window_timer(timer,'time',[],total_size,n_done);
        rt_str = [num2str(timer.rt,2),' ',timer.units];
        time_str = ['Estimated time remaining: ',rt_str];

    else
        
        % Empty outputs
        n_done = 0;
        time_str = '';
                
    end 
    
    % Print job status
    status = [s.nn,num2str(n_done),' out of ',num2str(total_size),' ',msg,' ',time_str];
    n_back = print_status(status, n_back);

end






