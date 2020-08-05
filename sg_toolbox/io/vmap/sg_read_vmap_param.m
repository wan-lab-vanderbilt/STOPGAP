function param = sg_read_vmap_param(rootdir,paramfilename)
%% sg_read_vmap_param
% A function for reading a STOPGAP variance map parameter file. 
%
% WW 01-2019

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,paramfilename], false, [], 'stopgap_vmap_parameters');
catch
    error(['ACHTUNG!!! Error reading ',paramfilename,'!!!']);
end

% Evaluate field types
field_types = sg_get_ordered_vmap_input_fields;
param = sg_evaluate_field_types(s, field_types);




