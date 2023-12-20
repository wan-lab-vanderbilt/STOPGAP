function timings = read_tps_timings(filename)
%% read_tps_timings
% Read a stopgap formatted timing .star file. 
%
% WW 10-2022

%% Read file

% Initialize file format
fieldtypes = {'num','str','str','str', 'num'};

% Read file
timings = stopgap_star_read(filename, 1, fieldtypes, 'stopgap_tps_timings');



