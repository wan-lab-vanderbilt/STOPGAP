function check_directories(p,o,idx)
%% 
% Check the existence of directories in the rootdir. If they don't exist,
% make them.
%
% WW 06-2019

%% Check check

% Parse directory fields
fields = fieldnames(o);
n_fields = numel(fields);
d_idx = false(n_fields,1);
for i = 1:n_fields
    d_idx(i) = strcmp(fields{i}(end-2:end),'dir');
end
d_idx = find(d_idx)';

% Check and make directories
for i = d_idx
    d_name = [p(idx).rootdir,'/',o.(fields{i})];
    if ~exist(d_name,'dir')
        mkdir(d_name);
    end
end



