function complete_parallel_tps(p,o,s,idx)
%% complete_parallel_tps
% A function to count the number of completed cores for the parallel
% power spectrum and write the completion file. 
%
% WW 10-2022

  
%% Wait for alignment to finish
    
% Wait until align completion
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_p_tps',(o.n_cores_p_tps*o.n_nodes),s.wait_time);


%% Complete parallel averaging

% Compile time
compile_tps_timings(p,o,idx,'p_tps');

% Update param file
disp([s.cn,' Parallel power spectra calcuation! Updataing parameter file...']);
[p,idx] = update_tps_param(s, p(idx).rootdir, s.paramfilename, idx, 'p');


% Write completion file
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_f_tps*']);    % Prevents overrun at next step...
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_f_tps']);    % Prevents overrun at next step...
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_p_tps']);
disp([s.cn,'Parallel tube power spectrum calculation complete!!!']);
                        
