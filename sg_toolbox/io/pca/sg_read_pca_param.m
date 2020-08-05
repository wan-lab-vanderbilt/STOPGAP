function param = sg_read_pca_param(rootdir,paramfilename)
%% read_pca_param
% A function for reading a STOPGAP PCA parameter file. 
%
% WW 01-2019

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,paramfilename], false, [], 'stopgap_pca_parameters');
catch
    error(['ACHTUNG!!! Error reading ',paramfilename,'!!!']);
end

% Evaluate field types
field_types = sg_get_ordered_pca_input_fields;
param = sg_evaluate_field_types(s, field_types);
