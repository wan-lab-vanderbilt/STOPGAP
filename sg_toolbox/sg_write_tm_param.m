function write_tm_param(param,rootdir,paramfilename)
%% write_tm_param
% Write stopgap param file to .star file with standard parameters.
%
% WW 01-2019

%% Write!!!!

stopgap_star_write(param,[rootdir,'/',paramfilename],'stopgap_tm_parameters', [], 4, 2);

