function stopgap_tm_watcher(rootdir,param_name,n_cores, submit_cmd)
%% stopgap_tm_watcher
% A function to watch the progress of a STOPGAP Template Matching 
% job.
%
% WW 01-2019

% % % % % % % DEBUG
rootdir = '/dors/wan_lab/home/wanw/research/2024/20241206_wanw_hardenn_sCANC_TOMO/subtomo/bin8/tm/';
param_name = 'params/tm_param.star';
n_cores = 200;


%% Check check

% Intialize settings struct
s = struct();
s.cn = 'Watcher: ';


% Check input arguments
if nargin == 3
    submit_cmd = [];
elseif (nargin < 3) || (nargin > 4)
    error([s.cn,'ACHTUNG!!! Incorrect number of inputs!!!']);
end


%% Initialize

% Convert to string
if ischar(n_cores); n_cores = eval(n_cores); end


% Check system dependencies
disp('Checking system dependencies...');
dependencies = {'rsync','cat','wc'};

for i = 1:numel(dependencies)
    [d_test,~] = system(['which ',dependencies{i}]);
    if d_test ~= 0
        error([nn,'ACHTUNG!!! ',dependencies{i},' appears to be missing!!!']);
    end
end
disp('System dependencies checked!!!');


% Read parameter file
[p,idx] = update_tm_param(s ,rootdir,param_name);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read in settings
s = sg_get_tm_settings(s,p(idx).rootdir,'tm_settings.txt');


% Initialize struct array to hold objects
o = struct();
o.n_cores = n_cores;
o = sg_parse_tm_directories(p,o,s,idx);


% Generate blank folder
if exist([p(idx).rootdir,'/blank/'],'dir')
    system(['rm -rf ',p(idx).rootdir,'/blank/']);
end
system(['mkdir ',p(idx).rootdir,'/blank/']);


%% Submit job

% Submit job
if ~isempty(submit_cmd)
    
    % Clear folders
    system(['rm -rf ',p(idx).rootdir,'/',o.commdir,'/*']);
    
    % Submit job
    disp([s.cn,'Submitting job...']);
    system(submit_cmd);
    
else
    
    disp([s.cn,'No submission command given... Watching pre-submitted job...']);    
    
end



%% Start watching...


run = true;
while run    
    
    %%%%% Initialize run %%%%%
    
    % Initialize settings
    o = sg_parse_tm_directories(p,o,s,idx);     % Parse iteration directories into the o struct
    check_directories(p,o,idx);
%     o = refresh_wedgelist(p,o,s,idx);        % Initialize wedgelist     
%     o = tm_get_total_angles(p,o,s,idx);   % Get number of angles to be matched        
    
    
    % Parse tomogram number
    o.tomo_num = num2str(p(idx).tomo_num);
        
    
    disp([s.cn,'Starting template matching on tomogram ',num2str(p(idx).tomo_num),'...']);
    
    if ~p(idx).completed_p_tm
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check for masked regions
        if sg_check_param(p(idx),'tomo_mask_name')
            disp([s.cn,'Tomogram mask detected... Determining masked regions...']);

            % Wait for Z-index file
            idx_name = ['tomo',num2str(p(idx).tomo_num),'_bounds.csv'];
            wait_for_it([p(idx).rootdir,'/',s.tempdir],idx_name,s.wait_time);

            disp([s.cn,'Masked regions determined...'])
        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Read number of matches
        matchlist_name = ['tm_matchlist_',num2str(p(idx).tomo_num),'.csv'];
        wait_for_it([p(idx).rootdir,'/',o.commdir],matchlist_name,s.wait_time);        
        n_matches = dlmread([p(idx).rootdir,o.commdir,matchlist_name]);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Parallel template matching
        disp([s.cn,'Performing parallel template matching...']);

        % Wait for all matches
        watch_progress(p,o,s,idx,'ptmprog',n_matches,false,'orientations matched...',20);
    
    end

    
    
    % Wait for step to complete
    wait_for_them([p(idx).rootdir,o.commdir],['sg_ptm_',o.tomo_num],o.n_cores,s.wait_time);
    fprintf('\n%s\n',[s.cn,'All orientations matched!!! Waiting for completed maps...']);
    wait_for_it([p(idx).rootdir,'/',o.commdir,'/'],['complete_final_tm_',o.tomo_num],s.wait_time);
    fprintf('%s\n\n',[s.cn,'Template matching on tomogram ',num2str(p(idx).tomo_num),' complete!!!']);   
    
    % Refresh parameter file
    [p,idx] = update_tm_param(s,rootdir,param_name);
    if isempty(idx)
        disp([s.cn,'All jobs in param file are completed!!!']);
        run = false;
    end

        
end
        




