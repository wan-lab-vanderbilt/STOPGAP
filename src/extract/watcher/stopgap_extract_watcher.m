function stopgap_extract_watcher(rootdir,param_name,n_cores, submit_cmd)
%% stopgap_extract_watcher
% A function to watch the progress of STOPGAP subtomogram extraction. 
%
% WW 04-2021

% % % % % % % % DEBUG
% rootdir = '/dors/wan_lab/home/wanw/research/mintu/13gr_14sq_6tomo_nccat_data/aretomo/subtomo/tube/bin4/init/';
% param_name = 'params/extract_param.star';
% n_cores = 1;


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
[p,idx] = update_extract_param(s ,rootdir,param_name);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read in settings
s = sg_get_extract_settings(s,p(idx).rootdir,'extract_settings.txt');


% Initialize struct array to hold objects
o = struct();
o.n_cores = n_cores;
o = sg_parse_extract_directories(p,o,s,idx);


% Generate blank folder
if exist([p(idx).rootdir,'/blank/'],'dir')
    system(['rm -rf ',p(idx).rootdir,'/blank/']);
end
system(['mkdir ',p(idx).rootdir,'/blank/']);


%% Submit job

% Submit job
if ~isempty(submit_cmd)
    
    % Clear folders
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/*']);
    
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
    o = sg_parse_extract_directories(p,o,s,idx);    % Parse iteration directories into the o struct
    check_directories(p,o,idx);                     % Check that directories exist
    o.rootdir = p(idx).rootdir;                     % Set rootdir
    o = extract_initialize_motivelist(p,o,s,idx);   % Initialize motivelist
    
    disp([s.cn,'Starting subtomogram extraction for motivelist ',p(idx).motl_name,'...']);
    
    
    % Watch progress
    watch_progress(p,o,s,idx,['exdone_',num2str(idx)],o.n_tomos,false,'tomograms extracted...',3,false);        
    
    
    % Wait for step to complete
    fprintf('\n%s\n',[s.cn,'All tomograms extracted!!! Waiting for run to finish...']);
    wait_for_it([p(idx).rootdir,'/',o.commdir,'/'],['complete_extraction_',num2str(idx)],s.wait_time);
    fprintf('%s\n\n',[s.cn,'Subtomogram extraction complete for motivelist ',p(idx).motl_name,'!!!']);   
    
    % Refresh parameter file
    [p,idx] = update_extract_param(s,rootdir,param_name);
    if isempty(idx)
        disp([s.cn,'All jobs in param file are completed!!!']);
        run = false;
    end

        
end
        




