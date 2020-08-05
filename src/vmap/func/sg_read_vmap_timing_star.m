function timings = sg_read_vmap_timing_star(filename)
%% sg_read_vmap_timing_star
% Read a stopgap formatted timing .star file. 
%
% WW 09-2018

%% Read file

% Initialize file format
fieldtypes = {'num','str','str','str','str','num'};

% Read file
timings = stopgap_star_read(filename, 1, fieldtypes, 'stopgap_vmap_timings');



