function check_folders(rootdir,varargin)
%% check_folders
% A function to check if folders exist in the rootdir; if they don't they
% are created.
%
% WW 08-2018

%% Check check!!!

for i = 1:numel(varargin)
    
    [dir,~,~] = fileparts(varargin{i});
    full_dir = [rootdir,'/',dir,'/'];
    
    if ~exist(full_dir)
        mkdir(full_dir);
    end
    
end

        

