function [p, idx] = update_param(rootdir, paramfilename, iteration, subtomo_mode, subtomo_step)
%% update_param
% A function to read and update a 'stopgap' parameter file.
% 
% v1: WW 11-2017
% v2: WW 01-2018 Updated to match new parameter file formats. Also updated
% to take new star read/write than tolerates comma-separated numeric
% arrays.
% 
% WW 01-2018

global nn

%% Check check

if nargin == 2
    iteration = 'none';    
    subtomo_mode = 'none';
    subtomo_step = 'none';
elseif nargin ~= 5
    error('Achtung!!! Incorrect number of inputs!!!');
end
   
% Check subtomo_step
if ~strcmp(subtomo_step,'none')
 
    % Set completion type
    switch subtomo_step
        case 'ali'
            comp = 'completed_ali';
        case 'p_aver'
            comp = 'completed_p_aver';
        case 'f_aver'
            comp = 'completed_f_aver';
        otherwise
            error('Achutng!!! Invalid subtomo_step parameter!!!');
    end
   
end



%% Read param

% Read parameter file
if exist([rootdir,'/',paramfilename],'file')
    try
        p = will_star_read([rootdir,'/',paramfilename]);
    catch
        error([nn,'Achtung!!!! Error reading parameter file: ',paramfilename]);
    end
else
    error([nn,'Achtung!!! ',paramfilename,' does not exist!!!']);
end


% Convert logical fields
fields = fieldnames(p);
l_fields = {'completed_ali','completed_p_aver','completed_f_aver','calc_ctf','calc_exposure','writefilt'};
for i = 1:numel(l_fields)
    if any(strcmp(l_fields{i},fields))        
        l = num2cell(cellfun(@(x) logical(x),{p.(l_fields{i})}));
        [p.(l_fields{i})] = l{:};
    end
end


%% Update

% Find matching parameters
if ~strcmp(iteration,'none') && ~strcmp(subtomo_mode,'none')
    
    % Determine matches for iteration and subtomo_mode
    idx_iter = ([p.iteration] == iteration);
    idx_mode = strcmp({p.subtomo_mode},subtomo_mode);


    % Check for update or refresh
    if ~strcmp(subtomo_step,'none')    % Update param file
        
        % For updating
        idx_comp = ([p.(comp)] == false);
        idx = find(idx_iter & idx_mode & idx_comp);
        
        % Check for proper match
        if isempty(idx)
            error('Achtung!!! No matching job found!!!');
        elseif numel(idx)>1
            idx = find(idx,1);
            warning(['Achutng!!! Too many job matches, updating the first matching row: ',num2str(idx)]);
        end
        
        % Update
        p(idx).(comp) = true;

        % Write file
        will_star_write(p,[rootdir,'/',paramfilename]);
        
    else
        
        % Gew new index
        idx = find(idx_iter & idx_mode);
                
        % Check for proper match
        if isempty(idx)
            error('Achtung!!! No matching job found!!!');
        elseif numel(idx)>1
            error('Achutng!!! Too many matches!!!')
        end
        
    end
    
    
    
else
    
    % Find unfinished index
    idx = find(~[p(:).completed_f_aver],1,'first'); % completed_f_aver shows an incomplete iteration.
    
end



    
    
    

