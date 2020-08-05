function [p,idx] = update_tm_param(s,rootdir, param_name, idx, step)
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
        p = sg_read_tm_param(rootdir,param_name);
    catch
        error([s.nn,'Achtung!!!! Error reading parameter file: ',param_name]);
    end
else
    error([s.nn,'Achtung!!! ',param_name,' does not exist!!!']);
end


%% Update index

% Return if index given
if nargin == 5
    
    % Update job
    switch step
        case 'p'
            p(idx).completed_p_tm = true;
        case 'f'
            p(idx).completed_f_tm = true;
    end
    

    % Write output
    sg_write_tm_param(p,rootdir,param_name);
    
end



% Update index
idx = find(~[p.completed_f_tm],1,'first');



