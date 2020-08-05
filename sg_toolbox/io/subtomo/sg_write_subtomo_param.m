function sg_write_subtomo_param(param,rootdir,paramfilename)
%% sg_write_subtomo_param
% Write stopgap param file to .star file with standard parameters.
%
% WW 05-2018

%% Write!!!!

stopgap_star_write(param,[rootdir,'/',paramfilename],'stopgap_subtomo_parameters', [], 4, 2);

