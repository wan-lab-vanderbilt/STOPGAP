function [p, idx] = update_subtomo_param(s, rootdir, paramfilename, iteration, subtomo_mode,subtomo_step)
%% update_subtomo_param
% A function to read and update a 'stopgap' parameter file. 
%
% When an iteration number of subtomo_mode  and subtomo_step are given, the 
% first uncompleted entry with matching parameters is set to complete.
%
% Subtomo steps are given as 'ali','p_aver', and 'f_aver'.
% 
% WW 05-2018


%% Check check

if nargin == 3
    iteration = 'none';    
    subtomo_mode = 'none';
elseif nargin ~= 6
    error([s.nn,'ACHTUNG!!! Incorrect number of inputs!!!']);
end
   


%% Read param

% Read parameter file
if exist([rootdir,'/',paramfilename],'file')
    try
        p = sg_read_subtomo_param(rootdir,paramfilename);
    catch
        error([s.nn,'Achtung!!!! Error reading parameter file: ',paramfilename]);
    end
else
    error([s.nn,'Achtung!!! ',paramfilename,' does not exist!!!']);
end



%% Update

% Find matching parameters
if ~strcmp(iteration,'none') && ~strcmp(subtomo_mode,'none')
    
    % Determine matches for iteration and subtomo_mode
    idx_iter = ([p.iteration] == iteration);
    idx_mode = strcmp({p.subtomo_mode},subtomo_mode);
    idx_uncomp = ~[p.(['completed_',subtomo_step])];

    % Gew new index
    idx = find(idx_iter & idx_mode & idx_uncomp);

    % Check for proper match
    if isempty(idx)
        error([s.nn,'ACHTUNG!!! No matching job found!!!']);
    elseif numel(idx)>1
        warning([s.nn,'ACHTUNG!!! Too many matches!!! Updating first match in index ',num2str(idx(1)),'!!!']);        
        idx = idx(1);
    end            
    
    % Set step completed
    p(idx).(['completed_',subtomo_step]) = true;
    
    % Overrite param
    sg_write_subtomo_param(p,p(idx).rootdir,paramfilename);
    
    % Return incremented index
    if strcmp(subtomo_step,'f_avg')
        idx = idx  + 1;
    end
    
    
else
    
    % Find unfinished index
    idx = find(~[p.completed_f_avg],1,'first');
    
end



    
    
    

