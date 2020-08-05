function complete_parallel_vmap(rootdir,param_name,p,o,s,idx)
%% complete_parallel_vmap
% A function to count the number of completed cores for the parallel
% variance map calcuation and write the completion file. 
%
% WW 05-2019


%% Complete parallel variance
  

% Wait until parallel variance completion
disp([s.nn,' Waiting for parallel variance calculation to complete...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_p_vmap',o.n_cores,s.wait_time);

% Compile time
compile_vmap_timings(p,o,idx,'p_vmap');

% Update param file
disp([s.nn,' Parallel variance calculations complete! Updataing parameter file...']);
[p,idx] = update_vmap_param(s,rootdir, param_name, idx, 'p_vmap');


% Write completion file
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_p_vmap_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_f_vmap']);    % Prevents overrun at next step...
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_p_vmap']);
disp([s.nn,'Parallel variance calculations complete!!!']);
                        
