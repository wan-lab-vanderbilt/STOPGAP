function complete_final_average(rootdir,paramfilename,p,idx,o,s)
%% complete_final_average
% A function to count the number of completed cores for the final
% average and write the completion file. 
%
% WW 07-2018

%% Complete final averaging

% Wait until final averaging completion
disp([s.nn,'Waiting for all final averages...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_f_avg',o.n_classes,s.wait_time);

% Check for empty classes
check_empty_classes(p,o,s,idx);

% Compile time
compile_subtomo_timings(p,o,idx,'f_avg');

% Update param file
disp([s.nn,'Final averaging complete! Updating parameter file....']);
old_idx = idx;
[p,idx] = update_subtomo_param(s ,rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'f_avg');        

% Cleanup
disp([s.nn,'Cleaning up iteration...']);
system(['rsync -a --delete ',p(idx-1).rootdir,'blank/ ',o.tempdir,'/']);

% Write completion files
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/aliprog_*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_ali*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_p_avg*']);
% system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_f_avg*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_ali']);    % Prevents overrun at next step...
system(['touch ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_f_avg']);
disp([s.nn,'Final averaging complete!']);

