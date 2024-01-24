function s = sg_get_subtomo_settings(s,rootdir,override_name)
%% sg_get_subtomo_settings
% A function to initialize some global settings.
% 
% Settings can be overrided by giving an input override file.
%
% WW 03-2021

%% Initialize settings

default_settings = {'wait_time', 5;...
                    'tempdir', 'temp/';...
                    'commdir', 'comm/';...
                    'rawdir', 'raw/';...
                    'refdir', 'ref/';...
                    'maskdir', 'masks/';...
                    'listdir', 'lists/';...
                    'fscdir', 'fsc/';...
                    'subtomodir', 'subtomograms/';...
                    'metadir', 'meta';...
                    'specdir', 'spec/';...
                    'localtempdir',strtrim(get_environmental_variable('$LOCAL_TEMP'));...
                    'copy_function','tar';...
                    'subtomo_digits', 1;...
                    'vol_ext', '.mrc';...
                    'packets_per_core',5;...
                    'n_tries', 10;...
                    'counter_pct',5;...
                    'calc_ctf',true;...
                    'calc_exp',true;...
                    'fourier_crop',true;...
                    'fthresh',500;...
                    'fsc_fourier_cutoff',5;...
                    'fsc_n_repeats',5;...
                    'fsc_thresh_single',0.5;...
                    'fsc_thresh_split',0.143;...
                    'write_raw', false;...
                    };
                
for i = 1:size(default_settings,1)
    s.(default_settings{i,1}) = default_settings{i,2};
end
      
%% Check for overrides

    
% Read overrides
overrides = read_settings_override(rootdir,override_name);
    
if ~isempty(overrides)
    
    % Appy overrides
    for i = 1:size(overrides,1)
        % Check if setting is present for this task
        idx = strcmp(default_settings(:,1),overrides{i,1});
        if ~any(idx)
            continue
        end
        
        % Check type
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


% % Initialize volume read
% switch s.vol_ext
%     case '.em'
%         s.read_vol = @(rootdir,filename) sg_emread([rootdir,'/',filename]);
%     case '.mrc'
%         s.read_vol = @(rootdir,filename) single(sg_mrcread([rootdir,'/',filename]));
% end
% 
% % Initialize volume read
% switch s.vol_ext
%     case '.em'
%         s.write_vol = @(rootdir,filename,volume) sg_emwrite([rootdir,'/',filename],volume);
%     case '.mrc'
%         s.write_vol = @(rootdir,filename,volume,header,varargin) sg_mrcwrite([rootdir,'/',filename],volume,header,varargin);
% end


