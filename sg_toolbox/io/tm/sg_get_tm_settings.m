function s = sg_get_tm_settings(s,rootdir,override_name)
%% get_settings
% A function to initialize some global settings.
% 
% Settings can be overrided by giving an input override file.
%
% WW 05-2018

%% Initialize settings

default_settings = {'wait_time', 5;...
                    'counter_pct', 5;...
                    'tempdir', 'temp/';...
                    'commdir', 'comm/';...
                    'tmpldir', 'tmpl/';...
                    'maskdir', 'masks/';...
                    'mapdir', 'maps/';...
                    'listdir', 'lists/';...
                    'rawdir', 'raw/';...
                    'metadir', 'meta/';...
                    'vol_ext', '.mrc';...
                    'fourier_crop',true;...
                    'scoring_fcn', 'flcf'   ;...
                    'write_raw', false;...
                    };
                
for i = 1:size(default_settings,1)
    s.(default_settings{i,1}) = default_settings{i,2};
end
      
%% Check for overrides

if exist([rootdir,'/',override_name],'file')
    
    % Read overrides
    overrides = read_settings_override(rootdir,override_name);
    
    % Appy overrides
    for i = 1:size(overrides,1)
        % Check type
        idx = strcmp(default_settings(:,1),overrides{i,1});
        if isnumeric(default_settings{idx,2})
            parameter = str2double(overrides{i,2});
        elseif islogical(default_settings{idx,2})
            switch overrides{i,2}
                case {'0','false',0}
                    parameter = false;
                case {'1','true',1}
                    parameter = true;
            end
        else
            parameter = overrides{i,2};
        end
        
        % Override setting
        s.(default_settings{idx,1}) = parameter;
        
    end
    
end
