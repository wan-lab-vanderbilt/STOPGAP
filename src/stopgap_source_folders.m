function folders = stopgap_source_folders()
%% stopgap_source_folders
% Add STOPGAP folders to MATLAB path.
%
% WW 06-2019

%% Define folders

% Intialize parameter struct
f = struct();

% Add general directories
f.io = {'stopgap/','io/','func/','extract/'};

% Subtomogram alignment/averaging directories
f.subtomo = {'subtomo/parser/','subtomo/watcher/','subtomo/exec/','subtomo/func/'};

% Tempalte matching
f.temp_match = {'tm/parser/','tm/watcher/','tm/exec/','tm/func/'};

% PCA
f.pca = {'pca/parser/','pca/watcher/','pca/exec/','pca/func/'};

% Variance map
f.vmap = {'vmap/parser/','vmap/watcher/','vmap/exec/','vmap/func/'};

%% Concatenate folders      

% Parse fields from struct
fields = fieldnames(f);
n_fields = numel(fields);
folder_cell = cell(1,n_fields);
for i = 1:n_fields
    folder_cell{i} = f.(fields{i});
end

% Concatenate fields
folders = [folder_cell{:}];
