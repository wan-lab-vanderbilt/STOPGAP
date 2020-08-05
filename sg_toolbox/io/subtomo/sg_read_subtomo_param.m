function param = sg_read_subtomo_param(rootdir,paramfilename)
%% sg_read_subtomo_param
% A function for reading a stopgap subtomo parameter file. 
%
% WW 05-2018

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,paramfilename], false, [], 'stopgap_subtomo_parameters');
catch
    error(['ACHTUNG!!! Error reading ',paramfilename,'!!!']);
end

% Evaluate field types
field_types = sg_get_ordered_subtomo_input_fields;
param = sg_evaluate_field_types(s, field_types);

