function motl = read_motl(rootdir,motlname)
%% read_motl
% A function for reading a stopgap motivelist.
%
% WW 05-2018

%% Read!!!

% Read .star file
try
    s = stopgap_star_read([rootdir,motlname], false, [], 'stopgap_motivelist');
catch
    error(['ACHTUNG!!! Error reading ',motlname,'!!!']);
end

% Evaluate field types
field_types = get_motl_fields;
motl = evaluate_field_types(s, field_types);

