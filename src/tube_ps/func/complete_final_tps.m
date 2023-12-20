function complete_final_tps(p,idx,o,s)
%% complete_final_tps
% A function to count the number of completed cores for the final
% power spectrum calculation and write the completion file. 
%
% WW 10-2022

%% Complete final averaging

% Wait until final averaging completion
disp([s.cn,'Waiting for all final power spectra...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_f_tps',o.n_classes,s.wait_time);


% Compile time
compile_tps_timings(p,o,idx,'f_tps');

% Update param file
old_idx = idx;
disp([s.cn,' Final power spectra cacluation! Updataing parameter file...']);
[p,~] = update_tps_param(s, p(idx).rootdir, s.paramfilename, idx, 'f');       

% Cleanup
disp([s.cn,'Cleaning up iteration...']);
system(['rsync -a --delete ',p(old_idx).rootdir,'blank/ ',o.tempdir,'/']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/sg_p_tps*']);
system(['rm -f ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_p_tps']);    % Prevents overrun at next step...
if o.copy_local
    system(['rm -f ',o.rootdir,'/',o.commdir,'/*']);
    system(['rm -rf ',o.rootdir,'copy_comm/*']);
end

% Write completion files
system(['touch ',p(old_idx).rootdir,'/',o.commdir,'/complete_stopgap_f_tps']);
disp([s.cn,'Final calculations complete!']);

