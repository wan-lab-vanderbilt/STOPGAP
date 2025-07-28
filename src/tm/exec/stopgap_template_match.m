function stopgap_template_match(s)
%% stopgap_template_match
% Perform template matching with STOPGAP.
%
% WW 04-2021


%% Initialize

% Initialize node name
disp([s.cn,'Initializing STOPGAP for template matching...']);

% Read parameter file
disp([s.cn,'Reading parameter file...']);
[p,idx] = update_tm_param(s,s.rootdir, s.paramfilename);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in parameter file are completed!!!']);
end

% Read settings
disp([s.cn,'Reading settings...']);
s = sg_get_tm_settings(s,p(idx).rootdir,'tm_settings.txt');



% Initialize struct array to hold objects
o = initialize_o_struct(p,s,idx,'tm');



    
%% Begin big loop
run = true;
while run        
    disp([s.cn,'Begin template matching on index ',num2str(idx),'...']);
    
    % Initialize required variables
    o = sg_parse_tm_directories(p,o,s,idx);     % Parse iteration directories into the o struct
    o = tm_check_copy_local(p,o,s,idx);         % Check for local copying
    o = refresh_wedgelist(p,o,s,idx);        % Read wedgelist
    o = refresh_templates(p,o,s,idx);        % Read template and mask
    o = prepare_parallel_tm(p,o,s,idx);      % Calcalate coordinates of tiles   
    
    
    %%%%% Prepare for parallel template matching %%%%%    
    if ~p(idx).completed_p_tm
        disp([s.cn,'Starting parallel template matching on index ',num2str(idx),'...']);
        
        % Initialize         
        o = generate_tm_bpf(p,o,s,idx);             % Generate bandpass filter             
        o = initialize_fourier_crop_tm(o,s);        % Iniitalize Fourier cropping
        o = initialize_phase_randomization(p,o,s,idx);  % Generate noise maps
        disp([s.cn,'Optimizing FFT wisdom...']);
        optimize_fft_wisdom(o.tilesize,'single');    % Optimize fft



        %%%%% Perform parallel template matching %%%%%

        % Start timer
        t = struct();
        t = processing_timer_tm(t,'start',p,o,idx,'parallel_tm');

        % Parallel template match
        stopgap_parallel_tm(p,o,s,idx);  

        % Write output timings
        processing_timer_tm(t,'end',p,o,idx,'parallel_tm');

        % Check for local copying
        if o.copy_local
           tm_copy_local_temp_data(p,o,s,idx);
        end
        
        
        % Wait for iteration to finish
        if o.procnum == 1        
            wait_for_them([p(idx).rootdir,o.commdir],['sg_ptm_',o.tomo_num],o.n_cores,s.wait_time);
            compile_timings_tm(p,o,idx,'parallel_tm');
            [p,idx] = update_tm_param(s,s.rootdir, s.paramfilename, idx, 'p');
        end
        
    end

    
    
    
    
    %%%%% Final template matching %%%%%
    if o.procnum ~= 1
        % Wait for job completion
        disp([s.cn,'Waiting for completion of template matching on index ',num2str(idx),'...']);
        wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_final_tm_',o.tomo_num],s.wait_time);
        
        % Pause to wait for updated param file
        pause(s.wait_time);
        [p,idx] = update_tm_param(s,s.rootdir, s.paramfilename);
        
        
    else
        
        % Start timer
        t = struct();
        t = processing_timer_tm(t,'start',p,o,idx,'final_tm');
        
        % Assemble final maps
        stopgap_final_tm(p,s,o,idx);  
        
        % End timer
        processing_timer_tm(t,'end',p,o,idx,'final_tm');
        compile_timings_tm(p,o,idx,'final_tm');
        
        % Update param file
        old_idx = idx;
        [p,idx] = update_tm_param(s,s.rootdir, s.paramfilename, idx, 'f');
        
        % Remove temporary files
        system(['rm -f ',o.tempdir,'/*']);
        system(['rm -rf ',o.commdir,'/*']);

        % Write checkjob
        system(['touch ',p(old_idx).rootdir,'/',o.commdir,'complete_final_tm_',o.tomo_num]);
        
        
    end
        
    
    
    
    % Check for completion
    if isempty(idx)
        run = false;
    end
    

end

disp([s.cn,'All jobs complete!!!']);


