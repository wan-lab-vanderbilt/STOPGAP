function s = sg_get_tps_settings(s,rootdir,override_name)
%% sg_get_tps_settings
% A function to initialize some global settings.
% 
% Settings can be overrided by giving an input override file.
%
% WW 10-2022

%% Initialize settings

default_settings = {'wait_time', 5;...
                    'counter_pct', 5;...
                    'tempdir', 'temp/';...
                    'commdir', 'comm/';...
                    'refdir', 'ref/';...
                    'maskdir', 'masks/';...
                    'listdir', 'lists/';...
                    'subtomodir', 'subtomograms/';...
                    'specdir', 'spec/';...
                    'metadir', 'meta';...
                    'localtempdir','/tmp/';...
                    'vol_ext', '.mrc';...
                    'subtomo_digits', 1;...

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

%% Generate functions from settings

% Convert subtomogram number to string
s.subtomo_num = @(x) sprintf(['%0',num2str(s.subtomo_digits),'d'],x);
