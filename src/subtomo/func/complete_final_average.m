function complete_final_average(p,idx,o,s)
%% complete_final_average
% A function to count the number of completed cores for the final
% average and write the completion file. 
%
% WW 07-2018

%% Complete final averaging

% Wait until final averaging completion
disp([s.cn,'Waiting for all final averages...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_f_avg',o.n_classes,s.wait_time);

% Check for empty classes
check_empty_classes(p,o,s,idx);

% Compile time
compile_subtomo_timings(p,o,idx,'f_avg');

% Update param file
disp([s.cn,'Final averaging complete! Updating parameter file....']);
old_idx = idx;
[p,idx] = update_subtomo_param(s ,p(idx).rootdir, s.paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'f_avg');        

% Cleanup
disp([s.cn,'Cleaning up iteration...']);
system(['rsync -a --delete ',p(idx-1).rootdir,'blank/ ',o.tempdir,'/']);
system(['rm -rf ',p(old_idx).rootdir,'/',o.commdir,'/alipacket_*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/aliprog_*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_ali*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_p_avg*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/n_p_avg_',num2str(p(old_idx).iteration)]);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_ali']);    % Prevents overrun at next step...
if o.copy_local
    system(['rm -f ',o.rootdir,'/',o.commdir,'/*']);
    system(['rm -rf ',o.rootdir,'copy_comm/*']);
end

% Write completion files
system(['touch ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_f_avg']);
disp([s.cn,'Final averaging complete!']);

