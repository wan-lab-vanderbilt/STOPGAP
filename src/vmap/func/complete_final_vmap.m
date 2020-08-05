function complete_final_vmap(rootdir,param_name,p,o,s,idx)
%% complete_final_vmap
% A function to count the number of completed cores for the final
% average and write the completion file. 
%
% WW 07-2018

%% Complete final variance map
pause(30)
    

% Wait until final averaging completion
disp([s.nn,'Waiting for all final variance maps...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_f_vmap',o.n_classes,s.wait_time);

% Compile time
compile_vmap_timings(p,o,idx,'f_vmap');

% Update param file
disp([s.nn,'Final variance maps complete! Updating parameter file....']);
update_vmap_param(s,rootdir, param_name, idx, 'f_vmap');

% Cleanup
disp([s.nn,'Cleaning up iteration...']);
system(['rsync -a --delete ',p(idx).rootdir,'blank/ ',o.tempdir,'/']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_f_vmap_*']);

% Write completion files
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_p_vmap']);    % Prevents overrun at next step...
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_f_vmap']);
disp([s.nn,'Final varaince maps complete!']);

