function stopgap_subtomo(rootdir,paramfilename, procnum, n_cores)
%% stopgap_subtomo
% A function to perform subtomogram averaging with the STOPGAP framework. 
%
% This function allows for three types of aligment modes: singleref,
% multiref, and multiclass:
% In singleref, there is a single reference, the allmotl file is is a 2D 
% array, but can contain an arbitrary number of classes. The classes to be 
% aligned are defined by the iclass parameters; iclass of 0 means all
% classes will be aligned.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to add on-the-fly slice wedgemasks calculation
% along with CTF and expsoure reference filtering. Also added was angular
% search using arbitrary Euler triplets. 
% v3: WW 06-2019 Updated to work in full stopgap exectuable. Optimized for
% performace and function updated for general use.
%
% WW 01-2018


% % % % % % % % % DEBUG
% rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/sg_0.7.1_whitened/bin1_comp/';
% paramfilename = 'params/subtomo_param.star';
% procnum = 1;
% n_cores = 240;



%% Initialize

% Intialize settings struct
s = struct();

% Initialize node name
s.nn = ['Node',num2str(procnum),': '];

disp([s.nn,'Initializing...']);
avg_modes = sg_get_subtomogram_averaging_modes();


% Read parameter file
disp([s.nn,'Reading parameter file...']);
[p, idx] = update_subtomo_param(s,rootdir,paramfilename);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read settings
disp([s.nn,'Reading settings...']);
s = sg_get_subtomo_settings(s,p(idx).rootdir,'settings.txt');


% Initialize struct array to hold objects
o = struct();
o.procnum = procnum;
o.n_cores = n_cores;
o = sg_parse_subtomo_directories(p,o,s,idx);



% Cleanup comm folder
if o.procnum == 1
    system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
end

    

%% Begin big loop
run = true;
while run
    
    
    % Parse mode
    mode = strsplit(p(idx).subtomo_mode,'_');
    
    % Initialize required variables
    o = sg_parse_subtomo_directories(p,o,s,idx);     % Parse iteration directories into the o struct
    o = refresh_wedgelist(p,o,s,idx);             % Initialize wedgelist               
    o = get_random_seed(p,o,s,idx);               % Random seed for iteration


    % Subtomogram alignment route
    switch mode{1}
        
        %%%%% Subtomogram averaging %%%%%
        case 'ali'
            disp([s.nn,'Starting subtomogram alignment and averaging for iteration ',num2str(p(idx).iteration)]);
            
            if ~p(idx).completed_ali && ~any(strcmp(p(idx).subtomo_mode,avg_modes))
                
                % Start timing
                t = struct();
                t = processing_timer(t,'start',p,o,idx,'ali');
                
                % Initialize 
                o = refresh_motl(p,o,s,idx);                            % Initialize motivelist  
                o = check_motl_for_subtomo(p,o,s,idx);                  % Check motivelist
                o = get_subtomo_boxsize(p,o,s,idx);                     % Get boxsize
                o = generate_subtomo_bpf(p,o,s,idx);                    % Calculate bandpass filter
                o = initialize_fourier_crop_alignment(s,o);             % Initialize Fourier cropping
                o = refresh_subtomo_volumes(p,s,o,idx);                 % Refresh volumes          
                o = refresh_reflist(p,o,s,idx);                           % Refresh rlist
                o = load_subtomo_references(p,o,s,idx);                 % Load refs, and masks                
                o = get_alignment_angles(p,o,s,idx,'init');             % Calculate angle list
                o = initialize_motl_for_subtomo_alignment(p,o,s,idx);   % Initialize motivelist for alignment
                optimize_fft_wisdom(o.boxsize,'single');                % Optimize fft

                % Perform subtomogram alignment
                align_subtomos(p,o,s,idx);  
                
                % Write timing
                processing_timer(t,'end',p,o,idx,'ali');

                % Wait for completion of alignment step
                if o.procnum == 1
                    complete_subtomo_align(rootdir,paramfilename,p,o,s,idx);
                else
                    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_ali',s.wait_time);
                end

                % Refresh param file
                [p, idx] = update_subtomo_param(s,rootdir,paramfilename);

            end
            
            
            % Parallel average
            run_parallel_avg(p,o,s,idx,mode,rootdir,paramfilename);
            

        %%%%% Parallel averaging %%%%%
        case 'avg'
            
            run_parallel_avg(p,o,s,idx,mode,rootdir,paramfilename);
            
            
            
    end
    
    
    
    % Update param file
    [p,idx] = update_subtomo_param(s, rootdir, paramfilename);

    
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
    
      

    
    
end % End while
    
disp([s.nn,'Subtomogram averaging finished!!!']);

end 


%% Parallel averaging
function run_parallel_avg(p,o,s,idx,mode,rootdir,paramfilename)

disp([s.nn,'Starting parallel averaging for iteration ',num2str(p(idx).iteration)]);           

% Initialize
o = refresh_motl(p,o,s,idx);                                    % Refresh motivelist
o = refresh_reflist(p,o,s,idx);                                   % Refresh reflist
o = get_subtomo_boxsize(p,o,s,idx);                             % Get boxsize
o = load_subtomo_masks(p,o,s,idx,mode);                           % Load masks
o = check_supersampling(p,o,s,idx);                               % Check for supersampled average
o = initialize_motl_for_parallel_average(p,o,s,idx);            % Prepare motivelist for averaging
optimize_fft_wisdom(o.boxsize,'single');                        % Optimize fft

% Parallel weighted average 
if ~p(idx).completed_p_avg              

    % Compute parallel average
    if o.p_avg_node

        % Start timing
        t = struct();
        t = processing_timer(t,'start',p,o,idx,'p_avg');
        
        % Run parallel average
        disp([s.nn,'Begin parallel averaging...']);
        parallel_average(p,o,s,idx);
        clear parallel_average
        
        % Write timings
        processing_timer(t,'end',p,o,idx,'p_avg');
        
    else
        disp([s.nn,'Non-averaging node... waiting for completion...']);
    end

    % Wait for completion
    if o.procnum == 1
        complete_parallel_average(rootdir,paramfilename,p,o,s,idx)
    else
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_avg',s.wait_time);
    end
end


% Final concatenation
if ~p(idx).completed_f_avg

    % Compute final average
    if o.f_avg_node
        pause(10)
        
        % Start timing
        t = struct();
        t = processing_timer(t,'start',p,o,idx,'f_avg');
        
        % Run final averaging
        final_average(p,o,s,idx);
        clear final_average
        
        % Write timings
        processing_timer(t,'end',p,o,idx,'f_avg');
    end

    % Wait for completion
    if o.procnum == 1
        complete_final_average(rootdir,paramfilename,p,idx,o,s);
    else
        wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_avg',s.wait_time);
    end
end

end


