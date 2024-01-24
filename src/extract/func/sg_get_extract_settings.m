function s = sg_get_extract_settings(s,rootdir,override_name)
%% sg_get_extract_settings
% A function to initialize some global settings.
% 
% Settings can be overrided by giving an input override file.
%
% WW 04-2021

%% Initialize settings

default_settings = {'wait_time', 5;...
                    'tempdir', 'temp/';...
                    'commdir', 'comm/';...
                    'listdir', 'lists/';...
                    'subtomodir', 'subtomograms/';...
                    'metadir', 'meta/';...
                    'localtempdir',strtrim(get_environmental_variable('$LOCAL_TEMP'));...
                    'tomo_digits', 1;...
                    'tomo_ext', 'mrc';...
                    'subtomo_digits', 1;...
                    'n_tries', 10;...
                    'counter_pct',5;...
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
s.tomo_num = @(x) sprintf(['%0',num2str(s.tomo_digits),'d'],x);




