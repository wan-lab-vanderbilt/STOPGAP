function stopgap_tube_ps(s)
%% stopgap_tube_ps
% A function to calculate the unwrapped power spectra for subtomograms
% extracted from a tube surface. Specifically, each subtomogram is rotated 
% into the reference frame, padded, and "unwrapped" by converting slices 
% orthogonal to the tube axis from Cartesian space to cylindrincal polar 
% coordinates. From there, each radial layer is independently Fourier
% transformed; the amplitudes from each subtomogram are summed to genereate
% a power spectrum.
%
% WW 10-2022


%% Initialize

% Initialize node name
disp([s.cn,'Initializing STOPGAP for calcualting tube powerspectra...']);

% Read parameter file
disp([s.cn,'Reading parameter file...']);
[p,idx] = update_tps_param(s,s.rootdir, s.paramfilename);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in parameter file are completed!!!']);
end

% Read settings
disp([s.cn,'Reading settings...']);
s = sg_get_tps_settings(s,p(idx).rootdir,'tps_settings.txt');



% Initialize struct array to hold objects
o = initialize_o_struct(p,s,idx,'tps');
% o = initialize_o_struct(s);
% 
% % Parse directories
% o = sg_parse_tps_directories(p,o,s,idx);
% 
% 
% % Cleanup comm folder
% if o.procnum == 1
%     system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
% end


%% Begin big loop
run = true;
while run    
    disp([s.cn,'Begin calculating tube powerspectra on index ',num2str(idx),'...']);
    
    % Initialize required variables
    o = sg_parse_tps_directories(p,o,s,idx);                % Parse iteration directories into the o struct
    o = tps_check_copy_local(p,o,s,idx);                    % Check for local copying
    o = tps_load_motl(p,o,s,idx);                           % Load motivelist and radlist
    o = initialize_motl_for_parallel_tps(p,o,s,idx);        % Determinie parallel parameters and copy subtomograms
    o = get_subtomo_boxsize_tps(p,o,s,idx);                 % Get boxsize and check for cube
    o = tps_initialize_masks(p,o,s,idx);                    % Load mask and bandpass filter
    
    % Parallel power spectrum calculation 
    if ~p(idx).completed_p_tps              


        % Start timing
        t = struct();
        t = tps_processing_timer(t,'start',p,o,idx,'p_tps');

        % Run parallel average
        disp([s.cn,'Begin parallel averaging...']);
        tps_parallel_ps(p,o,s,idx);
        clear tps_parallel_ps

        % Write timings
        tps_processing_timer(t,'end',p,o,idx,'p_tps');


        % Wait for completion
        if o.procnum == 1
            complete_parallel_tps(p,o,s,idx);
        else
            wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_p_tps',s.wait_time);
        end
    end


    % Final concatenation
    if ~p(idx).completed_f_tps

        % Compute final average
        if o.f_tps_core
            pause(10)

            % Start timing
            t = struct();
            t = processing_timer(t,'start',p,o,idx,'f_tps');

            % Run final averaging
            tps_final_average(p,o,s,idx);
            clear tps_final_average

            % Write timings
            tps_processing_timer(t,'end',p,o,idx,'f_tps');
        end

        % Wait for completion
        if o.procnum == 1
            complete_final_tps(p,idx,o,s);
        else
            wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_stopgap_f_tps',s.wait_time);
        end
    end

    
    
    
    % Update param file
    [p,idx] = update_tps_param(s, s.rootdir, s.paramfilename);

    
    % Check for end of run and refresh parameters if necessary
    if isempty(idx)
        disp([s.cn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    elseif idx > size(p,1)
        disp([s.cn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    end
    
      

    
    
end % End while

% % Cleanup local temp
% if o.copy_local
%     if o.local_id == 1
%         disp([s.cn,'Clearing local temporary directory...']);
%         system(['rm -rf ',o.rootdir]);
%         disp([s.cn,'Local temporary directory cleared!!!']);
%     end
% end

    
    
disp([s.cn,'Tube power spectra calculations finished!!!']);

end 


