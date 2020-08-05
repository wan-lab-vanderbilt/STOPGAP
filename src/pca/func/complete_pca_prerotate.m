function complete_pca_prerotate(p,o,s,idx,paramfilename)
%% complete_pca_prerotate
% Complete the STOPGAP PCA prerotation step by compiling times and writing
% completion file. 
%
% WW 06-2019

%% Complete step

disp([s.nn,'Waiting for all volumes to be rotated...']);
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_rotvol',o.n_cores,s.wait_time);

disp([s.nn,'STOPGAP PCA pre-rotation complete... Compiling timings...']);

% Compile time
compile_pca_timings(paramfilename,p,o,idx,'rotvol');

% Update parameter file
update_pca_param(s,p(idx).rootdir, paramfilename,idx);

% Write completion file
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_rotvol_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/rotvolprog_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_rotvol_*']);
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_rotvol']);
disp([s.nn,'PCA parallel pre-rotation complete!!!']);






