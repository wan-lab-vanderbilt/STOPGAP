function o = sg_parse_subtomo_directories(p,o,s,idx)
%% sg_parse_subtomo_directories
% Parse directories from the param and settings files. The param file takes
% priority. Directories for the iteration are stored in o.
%
% WW 03-2021

%% Directory fields

% Directory fields
d_fields = {'tempdir', 'commdir', 'rawdir', 'refdir', 'maskdir', 'listdir', 'subtomodir','fscdir','metadir','localtempdir'};
if sg_check_param(p(idx),'ps_name') || sg_check_param(p(idx),'amp_name')
    d_fields = cat(2,d_fields,{'specdir'});
end
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

