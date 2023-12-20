function o = sg_parse_tps_directories(p,o,s,idx)
%% sg_parse_tps_directories
% Parse directories from the param and settings files. The param file takes
% priority. Directories for the iteration are stored in o.
%
% WW 10-2022

%% Directory fields

% Directory fields
d_fields = {'tempdir', 'commdir', 'refdir', 'maskdir', 'listdir', 'subtomodir','specdir', 'metadir'};

n_dir = numel(d_fields);

%% Parse fields

for i = 1:n_dir
    
    if sg_check_param(p(idx),d_fields{i})
        dir_name = p(idx).(d_fields{i});
    else
        dir_name = s.(d_fields{i});
    end
    
    % Check name
    o.(d_fields{i}) = sg_check_dir_slash(dir_name);
    
end

