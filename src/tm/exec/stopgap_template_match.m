function stopgap_template_match(rootdir,param_name, procnum, n_cores)
%% stopgap_template_match
% Perform template matching with stopgap.
%
% WW 05-2020

% % % % % % % % DEBUG
% rootdir = '/fs/pool/pool-plitzko/will_wan/test_sg_0.7.1/tm_test/';
% param_name = 'params/tm_param.star';
% procnum = '1';
% n_cores = '480';


%% Evaluate numeric inputs
if (ischar(procnum)); procnum=eval(procnum); end
if (ischar(n_cores)); n_cores=eval(n_cores); end


%% Initialize

% Intialize settings struct
s = struct();

% Initialize node name
s.nn = ['Node',num2str(procnum),': '];

disp([s.nn,'Initializing...']);

% Read parameter file
disp([s.nn,'Reading parameter file...']);
[p,idx] = update_tm_param(s,rootdir, param_name);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in parameter file are completed!!!']);
end

% Read settings
disp([s.nn,'Reading settings...']);
s = sg_get_tm_settings(s,p(idx).rootdir,'tm_settings.txt');



% Initialize struct array to hold objects
o = struct();
o.procnum = procnum;
o.n_cores = n_cores;

% Parse directories
o = sg_parse_tm_directories(p,o,s,idx);


% Cleanup comm folder
if o.procnum == 1
    system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
end


    
%% Begin big loop
run = true;
while run        
    
    % Initialize required variables
    o = sg_parse_tm_directories(p,o,s,idx);     % Parse iteration directories into the o struct
    o = refresh_wedgelist(p,o,s,idx);
    o = refresh_templates(p,o,s,idx);        % Read template and mask
    o = prepare_parallel_tm(p,o,s,idx);      % Calcalate coordinates of tiles
    
    % Parse tomogram number
    o.tomo_num = num2str(p(idx).tomo_num);
    
    
    %%%%% Prepare for parallel template matching %%%%%    
    if ~p(idx).completed_p_tm
        
        % Initialize         
        o = generate_tm_bpf(p,o,s,idx);             % Generate bandpass filter             
        o = initialize_fourier_crop_tm(o,s);        % Iniitalize Fourier cropping
        o = initialize_phase_randomization(p,o,s,idx);  % Generate noise maps
        disp([s.nn,'Optimizing FFT wisdom...']);
        optimize_fft_wisdom(o.tilesize,'single');    % Optimize fft



        %%%%% Perform parallel template matching %%%%%

        % Start timer
        t = struct();
        t = processing_timer_tm(t,'start',p,o,idx,'parallel_tm');

        % Parallel template match
        stopgap_parallel_tm(p,o,s,idx);  

        % Write output timings
        processing_timer_tm(t,'end',p,o,idx,'parallel_tm');


        % Wait for iteration to finish
        if o.procnum == 1        
            wait_for_them([p(idx).rootdir,o.commdir],['sg_ptm_',o.tomo_num],o.n_cores,s.wait_time);
            compile_timings_tm(p,o,idx,'parallel_tm');
            [p,idx] = update_tm_param(s,rootdir, param_name, idx, 'p');
        end
        
    end

    
    
    
    
    %%%%% Final template matching %%%%%
    if o.procnum ~= 1
        % Wait for job completion
        wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_final_tm_',o.tomo_num],s.wait_time);
        
        % Pause to wait for updated param file
        pause(s.wait_time);
        [p,idx] = update_tm_param(s,rootdir, param_name);
        
        
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
        [p,idx] = update_tm_param(s,rootdir, param_name, idx, 'f');
        
        % Remove temporary files
        system(['rm -f ',o.tempdir,'/*']);
        system(['rm -f ',o.commdir,'/*']);

        % Write checkjob
        system(['touch ',p(old_idx).rootdir,'/',o.commdir,'complete_final_tm_',o.tomo_num]);
        
        
    end
        
    
    
    
    % Check for completion
    if isempty(idx)
        run = false;
    end
    

end

disp([s.nn,'All jobs complete!!!']);


