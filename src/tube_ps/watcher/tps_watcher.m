function tps_watcher(rootdir,paramfilename,n_cores, submit_cmd)
%% tps_watcher
% A function to watch the progress of a STOPGAP tube power spectra 
% calculations.
%
% WW 10-2022

% % % % % % DEBUG
% rootdir = '/dors/wan_lab/home/wanw/research/mintu/VUKrios_Apr22/04202022_jacksolp_kendalak_retromer_43-3_META/subtomo/bin4/Position_28/init_ref3/';
% paramfilename = 'params/tps_param.star';
% n_cores = 256;


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
[p,idx] = update_tps_param(s,rootdir, paramfilename);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read in settings
s = sg_get_tps_settings(s,p(idx).rootdir,'tps_settings.txt');  % Get settings

    
%% Prepare for job


% Initialze o struct
o = struct();
o.n_cores = n_cores;

% Get paths
o = sg_parse_tps_directories(p,o,s,idx);

% Submit job
if ~isempty(submit_cmd)
    
    % Clear communication directory
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/*']);
    
    
    disp([s.cn,'Submitting job...']);
    system(submit_cmd);
else
    
    disp([s.cn,'No submission command given... Watching pre-submitted job...']);
    
end





%% Start watching...


run = true;
while run    
    
    o = sg_parse_tps_directories(p,o,s,idx);


    % Read motivelist
    motlname = [o.listdir,'/',p(idx).motl_name];
    motl = sg_motl_read2([p(idx).rootdir,motlname]); 


    
    % Determine number of classes
    switch p(idx).tps_mode
        case 'singleref'
            n_classes = 1;
        case 'multiclass'
            classes = unique(motl.class);            
            n_classes = numel(classes);
    end
       
    
    disp(['Starting tube power spectrum calculation for job ',num2str(idx),'...']);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Parallel
    if ~p(idx).completed_p_tps
    
        
        disp('Starting parallel tube power spectrum calculations...');
        
        % Wait until parallel completion
        watch_for_files(p,o,s,idx,'sg_p_tps',o.n_cores,' parallel power spectra maps calculated...');
        fprintf('\n%s\n',[s.cn,'Parallel spectra written!!! Waiting for completion of parallel step...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_tps',s.wait_time);
        fprintf('%s\n\n',[s.cn,'Parallel power spectrum calculations complete!!!']);        
                        
    end


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Final averaging
    if ~p(idx).completed_f_tps

        disp([s.cn,'Averaging final power spectrum maps...']);
        
        
        % Wait until final averaging completion
        watch_for_files(p,o,s,idx,'sg_f_tps',n_classes,' final spectra written...');
        fprintf('\n%s\n',[s.cn,'All power spectra written!!! Cleaning up job...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_tps',s.wait_time);
        fprintf('%s\n\n',['Tube power spectrum map calculations for job ',num2str(idx),' complete!!!']);
        
        % Refresh param file
        [p, idx] = update_tps_param(s,rootdir,paramfilename);
        
    end                

        
        
    % Check for end of run and refresh parameters if necessary
    if isempty(idx)
        disp([s.cn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    end
    
end


disp('Tube power spectra calculations complete!!!1!');



