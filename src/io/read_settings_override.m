function overrides = read_settings_override(rootdir,filename)
%% read_settings_override
% Read settings override file and return as a struct array.
%
% WW 05-2018

% Open .star file
fid = fopen([rootdir,filename],'r');
text = textscan(fid, '%s', 'Delimiter', '\n');

% Find non-empty indices
idx = find(cellfun(@(x) ~isempty(x),text{1}));
n_idx = numel(idx);

% Parse parameters
overrides = cell(n_idx,2);
for i = 1:n_idx
    overrides(i,:) = strsplit(text{1}{idx(i)},'=');
end


