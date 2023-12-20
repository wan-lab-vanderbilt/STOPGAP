function [p, idx] = update_tps_param(s, rootdir, param_name, idx, ps_step)
%% update_tps_param
% Update STOPGAP tube powerspectrum parameter file. At the start, the
% parameter file is reloaded; if an index is given, that one is updated to
% show completion.
%
% WW 10-2022


%% Reload parameter


% Read parameter file
if exist([rootdir,'/',param_name],'file')
    try
        p = sg_read_tps_param(rootdir,param_name);
    catch
        error([s.cn,'Achtung!!!! Error reading parameter file: ',param_name]);
    end
else
    error([s.cn,'Achtung!!! ',param_name,' does not exist!!!']);
end


%% Update index

% Return if index given
if nargin == 5
    
    % Update job
    switch ps_step
        case 'p'
            p(idx).completed_p_tps = true;
        case 'f'
            p(idx).completed_f_tps = true;
    end
    

    % Write output
    sg_write_tps_param(p,rootdir,param_name);
    
end



% Update index
idx = find(~[p.completed_f_tps],1,'first');



    
    
    

