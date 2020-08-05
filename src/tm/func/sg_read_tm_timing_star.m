function timings = sg_read_tm_timing_star(filename)
%% sg_read_tm_timing_star
% Read a stopgap formatted timing .star file. 
%
% WW 09-2018

%% Read file

% Initialize file format
fieldtypes = {'num','str','str','num','num','num'};

% Read file
timings = stopgap_star_read(filename, 1, fieldtypes, 'stopgap_tm_timings');



