function build_help(toolbox_dir)
%% build_help
% Build help files for the sg_toolbox.
%
% Inputs: 
% toolbox_dir: Directory of the STOPGAP toolbox. If not provided, the
% self-path of this function will be used. (str)
%
% WW 06-2024

%% Initialize

% Check check
if isempty(toolbox_dir)
    % Get self path
    [toolbox_dir,~,~] = fileparts(which('sg_parse_help'));
end
toolbox_dir = sg_check_dir_slash(toolbox_dir);

% Get .m files
d = dir([toolbox_dir,'*.m']);
n_files = numel(d);


%% Build help


