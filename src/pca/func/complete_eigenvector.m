function complete_eigenvector(p,o,s,idx,paramfilename)
%% complete_eigenvector
% Complete the end of the eigenvector calculation step(idx). 
%
% WW 06-2019

%% Compelte eigevector step

% Wait for all eigenvectors
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_f_eigenvec',o.n_filt,s.wait_time);      % Wait for parallel cores


% Compile time
compile_pca_timings(paramfilename,p,o,idx,'p_eigenvec');
compile_pca_timings(paramfilename,p,o,idx,'f_eigenvec');


% Clear intermediate files
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_p_eigenvec_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_f_eigenvec_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/eigenvecprog_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/',p(idx).eigenvol_name,'_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/wei_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_p_eigenvec*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_f_eigenvec*']);

% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_eigenvec']);
disp([s.nn,'PCA Eigenvector calculation complete!!!']);
