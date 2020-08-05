function [p,idx] = update_vmap_param(s,rootdir, param_name, idx, vmap_step)
%% update_tm_param
% Update STOPGAP Template Matching parameter file. At the start, the
% parameter file is reloaded; if an index is given, that one is updated to
% show completion.
%
% WW 01-2019

%% Reload parameter


% Read parameter file
if exist([rootdir,'/',param_name],'file')
    try
        p = sg_read_vmap_param(rootdir,param_name);
    catch
        error([s.nn,'Achtung!!!! Error reading parameter file: ',param_name]);
    end
else
    error([s.nn,'Achtung!!! ',param_name,' does not exist!!!']);
end


%% Update index

% Return if index given
if nargin ~= 3
    
    switch vmap_step
        case 'p_vmap'
            field = 'completed_p_vmap';
        case 'f_vmap'
            field = 'completed_f_vmap';
    end
    % Update job
    p(idx).(field) = true;

    % Write output
    sg_write_vmap_param(p,rootdir,param_name);
    
end



% Update index
idx = find(~[p.completed_f_vmap],1,'first');



