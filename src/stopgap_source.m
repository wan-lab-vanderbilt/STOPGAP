%% Stopgap source
% Add stopgap directories to path.
%
% WW 01-2018

% List of directories to add
folders = stopgap_source_folders;
n_folders = numel(folders);

% Get current folder
curr_dir = [pwd,'/'];


for i  = 1:n_folders
    
    % Full folder
    full_folder = [curr_dir,folders{i}];
    
    % Add to path
    addpath(genpath(full_folder));
    
end
