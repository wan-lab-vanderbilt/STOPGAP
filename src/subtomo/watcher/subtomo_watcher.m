function subtomo_watcher(rootdir,paramfilename, n_cores, submit_cmd)
%% subtomo_watcher
% Monitor the progress of a STOPGAP subtomogram averaging job.
%
% WW 06-2019


%% Initialize

% Intialize settings struct
s = struct();
s.nn = 'Watcher: ';

% Check system dependencies
disp([s.nn,'Checking system dependencies...']);
dependencies = {'rsync','cat','wc'};

for i = 1:numel(dependencies)
    [d_test,~] = system(['which ',dependencies{i}]);
    if d_test ~= 0
        error([nn,'ACHTUNG!!! ',dependencies{i},' appears to be missing!!!']);
    end
end
disp([s.nn,'System appears ready!!! Loading parameters...']);


% Read parameter file
[p,idx] = update_subtomo_param(s ,rootdir,paramfilename);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end


% Read in settings
s = sg_get_subtomo_settings(s,p(idx).rootdir,'settings.txt');  % Get settings

% Initialize struct array to hold objects
o = struct();
o.n_cores = n_cores;
o = sg_parse_subtomo_directories(p,o,s,idx);


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
    disp([s.nn,'Submitting job...']);
    system(submit_cmd);
    
else
    
    disp([s.nn,'No submission command given... Watching pre-submitted job...']);    
    
end


%% Start watching...


run = true;
while run   
    fprintf('\n\n\n\n%s\n\n',['Starting subtomogram averaging run for iteration ',num2str(p(idx).iteration),'...']);
    
    %%%%% Initialize run %%%%%
    
    % Check directories
    check_directories(p,o,idx);
    
    % Read allmotl file
    o = load_motivelist(p,o,s,idx);
    
	% Parse mode
    mode = strsplit(p(idx).subtomo_mode,'_');
    
    
    
    %%%%% Subtomogram Alignment %%%%%
        
    if ~p(idx).completed_ali && strcmp(mode{1},'ali')
        disp([s.nn,'Starting subtomogram alignment...']);
        
        % Parse job size
        if p(idx).subset < 100
            total_size = round_to_even(o.n_motls*(p(idx).subset/100));
        else
            total_size = o.n_motls;
        end
                    
        % Wait for all subtomograms
        watch_progress(p,o,s,idx,'aliprog',total_size,false,'subtomograms aligned...',20);
        
        % Wait for step to complete
        fprintf('\n%s\n',[s.nn,'All subtomograms aligned!!! Waiting for completion of alignment step...']);
        wait_for_it([p(idx).rootdir,'/',o.commdir,'/'],'complete_stopgap_ali',s.wait_time);
        
        % Refresh param file
        [p, idx] = update_subtomo_param(s,rootdir,paramfilename);
        
        % Read allmotl file
        o = load_motivelist(p,o,s,idx);
        
        fprintf('%s\n\n',[s.nn,'Subtomogram alignment complete!!!']);
        
        
    end
    
    
    %%%%% Parallel Averaging %%%%%
    if ~p(idx).completed_p_avg
        disp([s.nn,'Starting parallel averaging...']);
        
        % Determine number of parallel cores
        switch mode{1}
            case 'ali'
                n_cores_p_avg =  determine_n_p_avg_cores(o.n_motls,o.n_cores);
            case 'avg'
                n_cores_p_avg =  o.n_cores;
        end
        
        % Wait until parallel averaging completion
        watch_for_files(p,o,s,idx,'sg_p_avg',n_cores_p_avg,' parallel averages completed...');
        fprintf('\n%s\n',[s.nn,'Parallel averages written!!! Waiting for completion of parallel averaging step...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_avg',s.wait_time);
        fprintf('%s\n\n',[s.nn,'Parallel averaging complete!!!']);
        
        % Refresh param file
        [p, idx] = update_subtomo_param(s,rootdir,paramfilename);
                        
    end


    %%%%% Final Averaging %%%%%
    if ~p(idx).completed_f_avg
        disp([s.nn,'Starting final averaging...']);
        
        
        % Wait until final averaging completion
        watch_for_files(p,o,s,idx,'sg_f_avg',o.n_classes,' final averages written...');
        fprintf('\n%s\n',[s.nn,'All final averages written!!! Cleaning up iteration...']);
        
        % Wait for it
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_avg',s.wait_time);
        fprintf('%s\n\n',['Subtomogram averaging in iteration ',num2str(p(idx).iteration),' complete!!!']);
        
        % Refresh param file
        [p, idx] = update_subtomo_param(s,rootdir,paramfilename);
                        
    end



    
        
        
    % Check for end of run and refresh parameters if necessary
    if isempty(idx)
        disp([s.nn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    elseif idx > size(p,1)
        disp([s.nn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    end

    
end

fprintf('\n\n%s\n\n','STOPGAP Subtomogram Averaging complete!!!');











