function sg_write_extract_param(param,rootdir,paramfilename)
%% sg_write_extract_param
% Write stopgap param file to .star file with standard parameters.
%
% WW 04-2021

%% Write!!!!

stopgap_star_write(param,[rootdir,'/',paramfilename],'stopgap_extract_parameters', [], 4, 2);

