function param = sg_read_tps_param(rootdir,paramfilename)
%% sg_read_tps_param
% A function for reading a STOPGAP tube power spectrum parameter file. 
%
% WW 20-2022

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,paramfilename], false, [], 'stopgap_tps_parameters');
catch
    error(['ACHTUNG!!! Error reading ',paramfilename,'!!!']);
end

% Evaluate field types
field_types = sg_get_ordered_tps_input_fields;
param = sg_evaluate_field_types(s, field_types);