function complete_pca_ccmatrix(p,o,s,idx,paramfilename)
%% complete_pca_ccmatrix
% Complete the STOPGAP PCA CC-matrix calculation step by compiling times 
% and writing completion file. 
%
% WW 06-2019

%% Complete step

% Wait for compiling to finish
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_ccmatrix',o.n_filt,s.wait_time);
disp([s.nn,'STOPGAP PCA CC-matrix calculation complete... Compiling timings...']);

% Compile times
compile_pca_timings(paramfilename,p,o,idx,'p_ccmat');
compile_pca_timings(paramfilename,p,o,idx,'f_ccmat');

% Update param file
update_pca_param(s,p(idx).rootdir, paramfilename,idx);

% Clear intermediate files
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_ccmat_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/ccarray_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/ccmatprog_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_ccmat_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_p_ccmat*']);

% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_ccmat_',num2str(idx)]);
disp([s.nn,'PCA CC-matrix calculation complete!!!']);