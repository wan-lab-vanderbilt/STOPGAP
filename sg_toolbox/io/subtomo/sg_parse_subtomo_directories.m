function o = sg_parse_subtomo_directories(p,o,s,idx)
%% sg_parse_subtomo_directories
% Parse directories from the param and settings files. The param file takes
% priority. Directories for the iteration are stored in o.
%
% WW 12-2018

%% Directory fields

% Directory fields
d_fields = {'tempdir', 'commdir', 'rawdir', 'refdir', 'maskdir', 'listdir', 'subtomodir','fscdir','metadir'};
if sg_check_param(p(idx),'ps_name') || sg_check_param(p(idx),'amp_name')
    d_fields = cat(2,d_fields,{'specdir'});
end
n_dir = numel(d_fields);

%% Parse fields

for i = 1:n_dir
    
    if sg_check_param(p(idx),d_fields{i})
        o.(d_fields{i}) = p(idx).(d_fields{i});
    else
        o.(d_fields{i}) = s.(d_fields{i});
    end
    
end

