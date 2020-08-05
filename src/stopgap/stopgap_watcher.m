function stopgap_watcher(rootdir,paramfilename,n_cores, submit_cmd)
%% stopgap_watcher
% A script for monitoring the progress of STOPGAP jobs. 
%
% If a submit_cmd is given, stopgap_watcher first does some basic checks, 
% submits the job, then watches progress; this requires you to be able to 
% run programs on your submission node. Otherwise, this can be run without
% a submit_cmd, which then causes the watcher to watch an already running 
% job. 
%
% WW 06-2019


% % % % % % % % DEBUG
% rootdir = '/fs/pool/pool-plitzko/will_wan/test_sg_0.7.1/tm_test/';
% paramfilename = 'params/pca_param.star';
% n_cores = 128;
% submit_cmd = [];


%% Check input

% Evaluate numeric inputs
if (ischar(n_cores)); n_cores=eval(n_cores); end

% Check input arguments
if nargin == 3
    submit_cmd = [];
elseif (nargin < 3) || (nargin > 4)
    error([s.nn,'ACHTUNG!!! Incorrect number of inputs!!!']);
end

%% Determine task

% Parse data block name from param file
star_name = [rootdir,'/',paramfilename];
db_name = get_star_data_block(star_name);


%% Run task

switch db_name
    
    % Run subtomogram alignment/averaging
    case 'stopgap_subtomo_parameters'
        subtomo_watcher(rootdir,paramfilename, n_cores, submit_cmd);
        
    % Run template matching
    case 'stopgap_tm_parameters'
        stopgap_tm_watcher(rootdir, paramfilename, n_cores, submit_cmd);
     
    % Run parallel variance map 
    case 'stopgap_vmap_parameters'
        vmap_watcher(rootdir, paramfilename ,n_cores, submit_cmd);
        
    % Run PCA
    case 'stopgap_pca_parameters'
        pca_watcher(rootdir,paramfilename,n_cores, submit_cmd);
        
end

end


