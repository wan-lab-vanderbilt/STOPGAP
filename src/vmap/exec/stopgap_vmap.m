function stopgap_vmap(s)
%% stopgap_vmap
% Caculate a variance map using STOPGAP. Variance maps are caculated using
% Ben Himes' method of amplitude-weigthed phase differences.
%
% WW 06-2019




%% Initialize
disp([s.cn,'Initializing...']);

% Read parameter file
disp([s.cn,'Reading parameter file...']);
[p, idx] = update_vmap_param(s,rootdir,param_name);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read settings
disp([s.cn,'Reading settings...']);
s = sg_get_vmap_settings(s,p(idx).rootdir,'settings.txt');


% Initialize struct array to hold objects
o = struct();
o.procnum = s.procnum;
o.n_cores = s.n_cores;
o = sg_parse_vmap_directories(p,o,s,idx);

% Cleanup comm folder
if o.procnum == 1
    system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
end

    
%% Begin big loop
run = true;
while run
    

    % Initialize required variables
    o = sg_parse_vmap_directories(p,o,s,idx);     % Parse iteration directories into the o struct
    o = refresh_wedgelist(p,o,s,idx);          % Initialize wedgelist 
    o = vmap_load_motl(p,o,s,idx);             % Load motivelist
    o = get_subtomo_boxsize(p,o,s,idx);        % Get boxsize from subtomogram
    o = vmap_load_norm_mask(p,o,s,idx);        % Load normalization mask
    o = vmap_load_references(p,o,s,idx);       % Load references
    o = generate_subtomo_bpf(p,o,s,idx);       % Generate bandpass filter
    optimize_fft_wisdom(o.boxsize,'single');   % Optimize fft
    
    
    % Parallel weighted average 
    if ~p(idx).completed_p_vmap              


        % Start timing
        t = struct();
        t = processing_timer(t,'start',p,o,idx,'p_vmap');

        % Run parallel average
        disp([s.cn,'Begin parallel variance calculation...']);
        parallel_vmap(p,o,s,idx);

        % Write timings
        processing_timer(t,'end',p,o,idx,'p_vmap');


        % Wait for completion
        if o.procnum == 1
            complete_parallel_vmap(rootdir,param_name,p,o,s,idx);
        else
            disp([s.cn,'test 0']);
            wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_vmap',s.wait_time);
        end
        disp([s.cn,'Parallel variance complete!!!']);
        
        
    end

    disp([s.cn,'test 1...']);

    % Final concatenation
    if o.f_avg_node

        % Start timing
        t = struct();
        t = processing_timer(t,'start',p,o,idx,'f_vmap');

        % Run final averaging
        final_vmap(p,o,s,idx);

        % Write timings
        processing_timer(t,'end',p,o,idx,'f_vmap');
    end

     disp([s.cn,'test 2...']);
    
    % Wait for completion
    if o.procnum == 1
        complete_final_vmap(rootdir,param_name,p,o,s,idx);
    else
        disp([s.cn,'Non-final-averaging node... waiting for final maps...']);
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_vmap',s.wait_time);
    end
    
    
    % Refresh param
    [p,idx] = update_vmap_param(s,rootdir, param_name);

    
    % Check for end of run and refresh parameters if necessary
    if isempty(idx)
        disp([s.cn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    end

    

end





