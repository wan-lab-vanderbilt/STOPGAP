function timings = read_subtomo_timings(filename)
%% read_subtomo_timings
% Read a stopgap formatted timing .star file. 
%
% WW 09-2018

%% Read file

% Initialize file format
fieldtypes = {'num','str','str','str','str','num'};

% Read file
timings = stopgap_star_read(filename, 1, fieldtypes, 'stopgap_subtomo_timings');



