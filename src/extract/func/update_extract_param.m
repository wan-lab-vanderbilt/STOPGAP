function [p,idx] = update_extract_param(s,rootdir, param_name, idx)
%% update_extract_param
% Update STOPGAP subtomogram extraction parameter file. At the start, the
% parameter file is reloaded; if an index is given, that one is updated to
% show completion.
%
% WW 04-2021

%% Reload parameter


% Read parameter file
if exist([rootdir,'/',param_name],'file')
    try
        p = sg_read_extract_param(rootdir,param_name);
    catch
        error([s.cn,'Achtung!!!! Error reading parameter file: ',param_name]);
    end
else
    error([s.cn,'Achtung!!! ',param_name,' does not exist!!!']);
end


%% Update index

% Return if index given
if nargin == 4
    
    % Update job
    p(idx).completed = true;
    

    % Write output
    sg_write_extract_param(p,rootdir,param_name);
    
end



% Update index
idx = find(~[p.completed],1,'first');



