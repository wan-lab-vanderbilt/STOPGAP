function settings = read_settings(filename)
%% read_settings
% Read a STOPGAP settings file and return as cell array. 
%
% WW 01-2024

%% Read settings

% Open .star file
fid = fopen(filename,'r');
text = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

% Find non-empty indices
idx = find(cellfun(@(x) ~isempty(x),text{1}) & cellfun(@(x) ~startsWith(x,'#'),text{1}));
n_idx = numel(idx);

% Parse settings
settings = cell(n_idx,2);
for i = 1:n_idx
    
    % Split setting name and setting
    settings(i,:) = cellfun(@(x) strtrim(x),strsplit(text{1}{idx(i)},'='),'UniformOutput',false);
    
    % Check for environmental variables
    if startsWith(settings{i,2},'$')
        settings{i,2} = strtrim(get_environmental_variable(settings{i,2}));
    end
end



