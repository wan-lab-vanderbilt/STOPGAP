function env_var_str = get_environmental_variable(env_var)
%% get_environmental_variable
% Take the name of an input enviornmental variable and return the variable
% as a string. 
%
% WW 01-2024

%% Get environmental variable

% Echo
[~,env_var_str] = system(['echo ',env_var]);

