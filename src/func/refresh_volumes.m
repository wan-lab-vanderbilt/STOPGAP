function o = refresh_volumes(p,o,s,idx,vol_list)
%% refresh_volumes
% Refresh a set of volumes defined by an input volume list and parameter
% file. 
%
% WW 06-2019

%% Refresh volumes

% Number of volumes
n_vol = size(vol_list,1);

% Check for refresh
for i = 1:n_vol
    
    
    refresh = false; %#ok<NASGU>
    
    % Check parameter exists
    if isfield(p(idx),vol_list{i,1})
        if sg_check_param(p(idx),vol_list{i,1})
            refresh = true;
        else
            continue
        end
    else 
        continue
    end
        
    
    % Check starting or change
    if idx == 1
        refresh = true;
    elseif ~strcmp(p(idx).(vol_list{i,1}),p(idx-1).(vol_list{i,1}))
        refresh = true;
    end

    
    % Check if loaded
    if ~isfield(o,vol_list{i,2})
        refresh = true;
    end
    
    % Check Fourier crop
    if vol_list{i,4} && o.fcrop
        refresh = true;
    end
    
    % Refresh volume
    if refresh
        
        % Read volume
        name = [o.(vol_list{i,3}),'/',p(idx).(vol_list{i,1})];
        o.(vol_list{i,2}) = read_vol(s,p(idx).rootdir,name);
        
        % Fourier crop
        if vol_list{i,4} && o.fcrop
            o.(vol_list{i,2}) = sg_rescale_volume_realspace(o.(vol_list{i,2}),o.boxsize,'linear');
        end
        
    end
    
end
    
    

