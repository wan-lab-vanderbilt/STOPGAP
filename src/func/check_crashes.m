function crash_log = check_crashes(p,idx,crash_log)
%% check_crashes
% A functionf or checking if any STOPGAP crash files have been written. As
% each new file is written, it is displayed on the watcher terminal. 
%
% WW 06-2023

%% Check for crashes!!1!

% Cycle through crash long
for i = 1:numel(crash_log)
    
    % Check for new crash
    if ~crash_log(i)
        
        % Check for crash file
        crash_file_name = [p(idx).rootdir,'/crash_',num2str(i)];
        if exist(crash_file_name,'file')
        
            % Report crash file
            fprintf('%s\n',[]);
            system(['cat ',crash_file_name]);

            % Log crash
            crash_log(i) = true;
            
        end
    end
end

% Check if all jobs have crashed
if all(crash_log)
    error('ACHTUNG!!!1! All cores have crashed!!!');
end


        



