function [o,s] = sg_tm_refresh_settings(p,idx)
%% sg_tm_refresh_settings
% Refresh template matching settings given input parameters.
%
% WW 12-2019

%% Refresh settings

% Get settings
s = struct();
s = sg_get_tm_settings(s,p(idx).rootdir,'tm_settings.txt');

% Get paths
o = struct();
o = sg_parse_tm_directories(p,o,s,idx);



