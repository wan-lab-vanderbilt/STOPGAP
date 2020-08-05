function complete_pca_covariance_matrix(p,o,s,idx,paramfilename)
%% complete_pca_covariance_matrix
% Complete the STOPGAP PCA CC-matrix calculation step by compiling times 
% and writing completion file. 
%
% WW 06-2019

%% Complete step

% Wait for compiling to finish
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_covarmat',o.n_filt,s.wait_time);
disp([s.nn,'STOPGAP PCA covariance-matrix calculation complete... Compiling timings...']);

% Compile time
compile_pca_timings(paramfilename,p,o,idx,'p_covar');
compile_pca_timings(paramfilename,p,o,idx,'f_covar');

% Update param file
update_pca_param(s,p(idx).rootdir, paramfilename, idx);

% Clear intermediate files
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_covar_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/covarprog_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/',p(idx).covar_name,'_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_p_covar*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_f_covar*']);

% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_covar']);
disp([s.nn,'PCA covariance-matrix calculation complete!!!']);

