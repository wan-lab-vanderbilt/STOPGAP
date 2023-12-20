function o = mem_profiler(o,task)
%% mem_profiler
% STOPGAP memory profiler. This uses the pmap system call to determine the
% amount of memory being used at a given step of an interative function. 
%
% Tasks are part of setting up the profiler:
% Initialization (init) first requests the process ID, output filename, and 
% memory format. It also opens the  output .csv file in the root directory 
% of the processing folder. 
%
% Record (rec) records the memory usage at given step. It issues a system
% call to pmap on the given PID and writes output to the open .csv file.
%
% 'rec_last' records the memory of the last step in an iteration. This
% tells the profiler to insert a new line prior to the next recordings. 
%
% Close 'close' closes the file. 
%
% WW 09-2023

%% Profile 

switch task
    
    case 'init'
        
        % Initialize profiler struct
        o.mem_prof = struct();
        
        % Get PID
        o.mem_prof.pid = input('Input process ID: \n','s'); 
        
        % Get filename
        o.mem_prof.filename = input('Input output filename: \n','s');
        
        % Get recording format
        o.mem_prof.format = input('Input memory format (KB, MB, GB): \n','s');
        
        % Open file
        o.mem_prof.fid = fopen([o.rootdir,o.mem_prof.filename],'w');
        
        
    case {'rec', 'rec_last'}
        
        % Run pmap
        [~,pmap_output] = system(['pmap ',o.mem_prof.pid,' | tail -n 1']);
        
        % Parse KB
        kb = str2double(pmap_output(7:end-2));
        
        % Check formatting
        switch lower(o.mem_prof.format)
            case 'kb'
                mem = num2str(kb);
            case 'mb'
                mem = num2str(kb/1024);
            case 'gb'
                mem = num2str(kb/(1024^2));
        end
        
        % Write output
        fprintf(o.mem_prof.fid,'%s',mem);
        
        switch task
            case 'rec'
                fprintf(o.mem_prof.fid,'%s',', ');
            case 'rec_last'
                fprintf(o.mem_prof.fid,'\n');
        end
        
    case 'close'
        
        fclose(o.mem_prof.fid);
        
end
        
        
        



