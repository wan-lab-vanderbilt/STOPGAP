function [p,idx] = update_pca_param(s,rootdir, param_name, idx)
%% update_pca_param
% Update STOPGAP PCA parameter file. At the start, the parameter file is 
% reloaded; if an index is given, that one is updated to show completion.
%
% WW 01-2019

%% Reload parameter


% Read parameter file
if exist([rootdir,'/',param_name],'file')
    try
        p = sg_read_pca_param(rootdir,param_name);
    catch
        error([s.nn,'Achtung!!!! Error reading parameter file: ',param_name]);
    end
else
    error([s.nn,'Achtung!!! ',param_name,' does not exist!!!']);
end


%% Update index

% Return if index given
if nargin == 4
    
    % Complete step
    p(idx).completed = true;

    % Write output
    sg_write_pca_param(p,rootdir,param_name);
    
end



% Update index
idx = find(~[p.completed],1,'first');



