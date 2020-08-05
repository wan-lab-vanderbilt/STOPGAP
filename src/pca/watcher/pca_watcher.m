function pca_watcher(rootdir,paramfilename,n_cores, submit_cmd)
%% stopgap_pca_kontrolleur
% A function to watch the progress of a STOPGAP PCA job.
%
% WW 06-2019



% % % % % % % DEBUG
% rootdir = '/fs/pool/pool-plitzko/will_wan/test_sg_0.7.1/tm_test/';
% paramfilename = 'params/pca_param.star';
% n_cores = 128;


%% Check check

% Intialize settings struct
s = struct();
s.nn = 'Watcher: ';


% Check input arguments
if nargin == 3
    submit_cmd = [];
elseif (nargin < 3) || (nargin > 4)
    error([s.nn,'ACHTUNG!!! Incorrect number of inputs!!!']);
end


% Convert to string
if ischar(n_cores); n_cores = eval(n_cores); end



%% Initialize


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
disp([s.nn,'Reading parameter file...']);
[p,idx] = update_pca_param(s,rootdir, paramfilename);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in .param file compelted!!!']);
end

% Check tasks
tasks = sg_get_pca_tasks();
if ~any(strcmp(p(idx).pca_task,tasks))
    error(['ACHTUNG!!! Unsupported PCA task: ',pca_task,'!!!']);
end


% Read settings
disp([s.nn,'Reading settings...']);
s = sg_get_pca_settings(s,p(idx).rootdir,'pca_settings.txt');
    

% Initialize 'o' array
o = struct();
o.n_cores = n_cores;
o = sg_parse_pca_directories(p,o,s,idx);
o = load_filter_list(p,o,s,idx);    % Read in filter list


%% Prepare for job

% Parse directory fields
o_fields = fieldnames(o);
dir_idx = cellfun(@(x) ~isempty(x),regexp(o_fields,'dir$'));
d_fields = o_fields(dir_idx);

% Check directory existence
for i = 1:numel(d_fields)
    d = [p(idx).rootdir,'/',o.(d_fields{i})];
    if ~exist(d,'dir')
        system(['mkdir ',d]);
    end
end


% Submit job
if ~isempty(submit_cmd)
    
    % Clear communication directory
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/*']);
    
    
    disp([s.nn,'Submitting job...']);
    system(submit_cmd);
else
    
    disp([s.nn,'No submission command given... Watching pre-submitted job...']);
    
end



%% Start watching...
run = true;
while run
    
    % Reload lists
    o = sg_parse_pca_directories(p,o,s,idx);
    o = load_filter_list(p,o,s,idx);    % Read in filter list


    switch p(idx).pca_task

        case 'rot_vol'
            disp([s.nn,'STOPGAP PCA performing volume pre-rotation!!!']);
            watch_rot_vol(p,o,s,idx);

        case 'calc_ccmat'
            disp([s.nn,'STOPGAP PCA calculating CC-matrix!!!']);
            watch_ccmat(p,o,s,idx);

        case 'calc_pca_ccmat'
            disp([s.nn,'STOPGAP PCA calculating PCA, Eigenvolumes, and Eigenvalues!!!']);
            watch_pca_ccmat(p,o,s,idx);
        
        case 'calc_covar'
            disp([s.nn,'STOPGAP PCA calculating covariance matrix!!!']);
            watch_covar(p,o,s,idx);
            
        otherwise
            error([s.nn,'ACHTUNG!!! Unsupported PCA task!!!']);

        

    end
    
    % Update param file
    [p,idx] = update_pca_param(s,p(idx).rootdir, paramfilename);
    
    % Check for exit
    if isempty(idx)
        run = false;
    end
    
end

end



%% Pre-rotate volumes

function watch_rot_vol(p,o,s,idx)

    % Load motivelist
    motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    disp([s.nn,'Reading motivelist: ',motl_name]);
    motl = sg_motl_read2([p(idx).rootdir,'/',motl_name]);
    n_subtomos = numel(unique(motl.subtomo_num));
    clear motl
    
    disp([s.nn,'Starting to prerotate volumes...']);
    
    % Wait for rotations
    watch_progress(p,o,s,idx,'rotvolprog',n_subtomos,false,'subtomograms rotated...',20);
    

    % Wait for completion
    fprintf('\n%s\n',[s.nn,'All volumes rotated!!! Cleaning up after step...']);
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_rotvol',s.wait_time);
    fprintf('\n\n%s\n\n',[s.nn,'STOPGAP PCA pre-rotation completed!!!']);

end



%% Calcualte CC-matrix

function watch_ccmat(p,o,s,idx)

    % Load motivelist
    motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    disp([s.nn,'Reading motivelist: ',motl_name]);
    motl = sg_motl_read2([p(idx).rootdir,'/',motl_name]);
    n_subtomos = numel(unique([motl.subtomo_num]));
    clear motl
    
    % Calculate pairs
    n_pairs = ((n_subtomos^2)/2)-(n_subtomos/2);
    
    disp([s.nn,'Calculating pairwise cross-correlations...']);
    
    % Wait for rotations
    watch_progress(p,o,s,idx,'ccmatprog',n_pairs,false,'pairwise correlations calculated...',20);
    

    % Wait for completion
    fprintf('\n%s\n',[s.nn,'Parallel computations complete... waiting for final CC-matrices...']);
    wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_sg_pca_ccmat_',num2str(idx)],s.wait_time);
    fprintf('\n\n%s\n\n',[s.nn,'STOPGAP PCA CC-matrix completed!!!']);


end



%% Calcualte covariance matrix

function watch_covar(p,o,s,idx)

    % Load motivelist
    motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    disp([s.nn,'Reading motivelist: ',motl_name]);
    motl = sg_motl_read2([p(idx).rootdir,'/',motl_name]);
    n_subtomos = numel(unique(motl.subtomo_num));
    clear motl 

    
    %%% Parallel covaraince %%%
    disp('Starting parallel covariance matrix calculation...');    
    
    % Wait for all subtomograms
    watch_progress(p,o,s,idx,'covarprog',n_subtomos,false,'subtomograms processed...',20);

    
    
    %%% Final covaraince %%%
    fprintf('\n%s\n',[s.nn,'All subtomograms processed!!! Waiting for final covariance matrices...']);


    % Wait until final averaging completion
    watch_for_files(p,o,s,idx,'sg_pca_covarmat',o.n_filt,' covariance matrices completed...');
    fprintf('\n%s\n',[s.nn,'STOPGAP PCA covariance matrices calculated!!! Cleaning up iteration']);

    % Wait for completion
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_covar',s.wait_time);
    fprintf('\n\n%s\n\n',[s.nn,'STOPGAP PCA covariance-matrix completed!!!']);

end



%% Calculate PCA

function watch_pca_covar(p,o,s,idx)

    % Load motivelist
    motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    disp([s.nn,'Reading motivelist: ',motl_name]);
    motl = sg_motl_read([p(idx).rootdir,'/',motl_name]);
    subtomos = unique([motl.subtomo_num]);
    n_subtomos = numel(subtomos);
    clear motl subtomos

    
    %%%%% Calculate SVD and Eigenvectors %%%%%
    disp('Calculating SVD on each covariance-matrix!!!')
    
    n_pca = 0;
    n_back = 0;

    while n_pca < o.n_filt
        pause(s.wait_time);
        n_pca = numel(dir([o.commdir,'sg_pca_svd_*']));
        status = [num2str(n_pca),' out of ',num2str(o.n_filt),' SVDs completed...'];
        n_back = print_status(status, n_back);
    end

    fprintf(['\n','STOPGAP PCA SVD and eigenvectors calculated!!!\n']);
        

    
    
    %%%%% Calculate Eigenvalues %%%%%
    disp('Calculating Eigenvalues!!!')
    
    % Initialize timer
    timer = struct();
    timer = rolling_window_timer(timer,'init',10);
    % Wait for rotations
    n_eigenval = 0;
    n_back = 0;        
    while n_eigenval < n_subtomos
        pause(s.wait_time);
        if ~isempty(dir([p(idx).rootdir,'/',o.tempdir,'/eigenvalprog_*']));
            [~,n_eigenvec_str] = system(['cat ',p(idx).rootdir,'/',o.tempdir,'/eigenvalprog_* | wc -l']);
            n_eigenval = str2double(n_eigenvec_str);

            % Time estimation
            timer = rolling_window_timer(timer,'time',[],n_subtomos,n_eigenval);
            rt_str = [num2str(timer.rt,2),' ',timer.units];
            time_str = ['Estimated remaining time: ',rt_str];

        else
            n_eigenvec_str = '0 ';
            n_eigenval = 0;
            time_str = '';
        end            
        status = [n_eigenvec_str(1:end-1),' out of ',num2str(n_subtomos),' subtomograms processed... ',time_str];
        n_back = print_status(status, n_back);

    end
    
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_eigenval',s.wait_time);
    fprintf(['\n','Eigenvalue calculation complete!!!\n']);


end



%% Calculate PCA from ccmatrix

function watch_pca_ccmat(p,o,s,idx)

    % Load motivelist
    motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    disp([s.nn,'Reading motivelist: ',motl_name]);
    motl = sg_motl_read2([p(idx).rootdir,'/',motl_name]);
    n_subtomos = numel(unique(motl.subtomo_num));
    clear motl

    
    %%%%% Calculate PCA and eigenfactors %%%%%
    disp('Calculating PCA on each CC-matrix!!!')    

    % Wait until parallel averaging completion
    watch_for_files(p,o,s,idx,'sg_pca_eigenfactors',o.n_filt,' PCA calculations completed...');
    fprintf('\n%s\n',[s.nn,'STOPGAP PCA eigenfactors determined!!!']);
            

    
    
    %%%%% Calculate Eigenvolumes %%%%%
    disp('Calculating Eigenvolumes!!!')
    
    
    %%% Parallel averaging %%%
    disp('Starting parallel eigenvolume calculation...');    
    
    % Wait for all subtomograms
    watch_progress(p,o,s,idx,'eigenvecprog',n_subtomos,false,'subtomograms processed...',20);

    
    
    % Wait for step to complete
    fprintf('\n%s\n',[s.nn,'All subtomograms aligned!!! Waiting for final eigenvolumes...']);
    
    
    %%% Final averaging %%%
    fprintf('\n%s\n','Waiting for final eigenvolumes...');

    % Wait until final averaging completion
    watch_for_files(p,o,s,idx,'sg_pca_f_eigenvec',o.n_filt,' eigenvolume sets completed...');
    fprintf('\n%s\n',[s.nn,'STOPGAP PCA eigenvectors calculated!!! Cleaning up iteration']);
    
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_eigenvec',s.wait_time);
    fprintf(['\n','Eigenvolume calculation complete!!!\n']);
        
        
    
    %%%%% Calculate Eigenvalues %%%%%
    disp('Calculating Eigenvalues!!!')
    
    % Wait for all subtomograms
    watch_progress(p,o,s,idx,'eigenvalprog',n_subtomos,false,'subtomograms processed...',20);
    fprintf('\n%s\n',[s.nn,'STOPGAP PCA eigenvalues determined!!! Cleaning up iteration']);

    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_eigenval',s.wait_time);
    fprintf(['\n','Eigenvalue calculation complete!!!\n']);


end


