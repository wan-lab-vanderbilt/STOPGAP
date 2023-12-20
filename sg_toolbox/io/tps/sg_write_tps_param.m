function sg_write_tps_param(param,rootdir,paramfilename)
%% sg_write_tps_param
% Write stopgap param file to .star file with standard parameters.
%
% WW 10-2022

%% Write!!!!

stopgap_star_write(param,[rootdir,'/',paramfilename],'stopgap_tps_parameters', [], 4, 2);

