function param = sg_read_extract_param(rootdir,paramfilename)
%% sg_read_extract_param
% A function for reading a STOPGAP subtomogram extraction parameter file. 
%
% WW 04-2021

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,paramfilename], false, [], 'stopgap_extract_parameters');
catch
    error(['ACHTUNG!!! Error reading ',paramfilename,'!!!']);
end

% Evaluate field types
field_types = sg_get_ordered_extract_input_fields;
param = sg_evaluate_field_types(s, field_types);