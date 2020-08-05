function vmap_watcher(rootdir,paramfilename,n_cores, submit_cmd)
%% vmap_watcher
% A function to watch the progress of a STOPGAP variance map calculation.
%
% WW 06-2019

% % % % % DEBUG
% rootdir = '/fs/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/speed_test/bin1/shc_vmap/';
% paramfilename = 'vmap_param.star';
% n_cores = 400;


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
[p,idx] = update_vmap_param(s,rootdir, paramfilename);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read in settings
s = sg_get_vmap_settings(s,p(idx).rootdir,'vmap_settings.txt');  % Get settings

    
%% Prepare for job


% Initialze o struct
o = struct();
o.n_cores = n_cores;

% Get paths
o = sg_parse_vmap_directories(p,o,s,idx);

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
    
    o = sg_parse_vmap_directories(p,o,s,idx);


    % Read motivelist
    motlname = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
    motl = sg_motl_read2([p(idx).rootdir,motlname]); 
%     subtomos = unique([motl.subtomo_num]);
%     n_subtomo = numel(subtomos);

    
    % Determine number of classes
    switch p(idx).vmap_mode
        case 'singleref'
            n_classes = 1;
        case 'multiclass'
            classes = unique(motl.class);            
            n_classes = numel(classes);
    end
       
    
    disp(['Starting variance map calculation for job ',num2str(idx),'...']);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Parallel averaging
    if ~p(idx).completed_p_vmap
    
        
        disp('Starting parallel variance calculations...');
        
        % Wait until parallel averaging completion
        watch_for_files(p,o,s,idx,'sg_p_vmap',o.n_cores,' parallel variance maps calculated...');
        fprintf('\n%s\n',[s.nn,'Parallel maps written!!! Waiting for completion of parallel step...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_vmap',s.wait_time);
        fprintf('%s\n\n',[s.nn,'Parallel variance calculations complete!!!']);        
                        
    end


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Final averaging
    if ~p(idx).completed_f_vmap

        disp([s.nn,'Averaging final variance maps...']);
        
        
        % Wait until final averaging completion
        watch_for_files(p,o,s,idx,'sg_f_vmap',n_classes,' final maps written...');
        fprintf('\n%s\n',[s.nn,'All variance maps written!!! Cleaning up iteration...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_vmap',s.wait_time);
        fprintf('%s\n\n',['Variance map calculations for iteration ',num2str(p(idx).iteration),' complete!!!']);
        
        % Refresh param file
        [p, idx] = update_vmap_param(s,rootdir,paramfilename);
        
    end                

        
        
    % Check for end of run and refresh parameters if necessary
    if isempty(idx)
        disp([s.nn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    end
    
end


disp('Variance map calculations complete!!!1!');



