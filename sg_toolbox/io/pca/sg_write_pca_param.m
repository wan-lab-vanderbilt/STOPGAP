function sg_write_pca_param(param,rootdir,paramfilename)
%% sg_write_pca_param
% Write stopgap param file to .star file with standard parameters.
%
% WW 01-2019

%% Write!!!!

stopgap_star_write(param,[rootdir,'/',paramfilename],'stopgap_pca_parameters', [], 4, 2);

