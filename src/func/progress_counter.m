function [pc,str] = progress_counter(pc,task,total,pct)
%% progress_counter
% Function for initializing and displaying prompts from a progress counter.
% 
% WW 06-2019

%% Progress counter

switch task
    
    case 'init'
        
        % Initialize counter
        pc.tic = tic;                    % Time start
        pc.c = 0;                        % Progress
        pc.step_size = total*(pct/100);  % Report step size
        pc.report = pc.step_size;        % When to report progress
        
        
    case 'count'
        
        % Increment counter
        pc.c = pc.c + 1;
        
        % Report
        if pc.c >= pc.report
            
            % Increment report
            pc.report = pc.report + pc.step_size;
            
            % Time
            ct = toc(pc.tic);           % Current time
            tpc = ct./pc.c;             % Time per count
            rt = (total-pc.c)*tpc;      % Time remaining
            
            % Check units
            if rt > 3600
                rt = rt/3600;
                unit = 'hours';
            elseif rt > 60
                rt = rt/60;
                unit = 'minutes';
            else
                unit = 'seconds';
            end
            
            str = [num2str(rt,'%.1f'),' ',unit,' remaining...'];
            
        else
            str = [];
        end
end

            
