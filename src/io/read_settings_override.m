function overrides = read_settings_override(rootdir,filename)
%% read_settings_override
% Read settings override file and return as a struct array.
%
% WW 01-2023

%% Get global settings

% Get $STOPGAPHOME
STOPGAPHOME = strtrim(get_environmental_variable('$STOPGAPHOME'));

% Read global settings
if exist([STOPGAPHOME,'lib/global_settings.txt'],'file')
    global_settings = read_settings([STOPGAPHOME,'lib/global_settings.txt']);
else
    global_settings = [];
end


%% Get local settings

% Read local settings
if exist([rootdir,filename],'file')
    local_settings = read_settings([rootdir,filename]);
else
    local_settings = [];
end

%% Return overrides

% Concatenate
overrides = cat(1,global_settings,local_settings);

