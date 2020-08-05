function complete_eigenvalue(p,o,s,idx,paramfilename)
%% complete_eigenvalue
% Complete eigenvalue calculation
% 
% WW 06-2019


%% Compelte eigevector step

% Wait for all eigenvectors
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_eigenval',o.n_cores,s.wait_time);      % Wait for parallel cores
pause(s.wait_time*2);

% Compile time
compile_pca_timings(paramfilename,p,o,idx,'eigenval');

% Concatenate eigenvalues
[~,~,job_array] = job_start_end(o.n_subtomos,o.n_cores,o.procnum);
for i = 1:o.n_filt
    eigenval = zeros(o.n_subtomos,p(idx).n_eigs,'single');
    for j = 1:o.n_cores
        name = [o.tempdir,'/',p(idx).eigenval_name,'_',num2str(o.filtlist(i).filt_idx),'_',num2str(j),'.csv'];
        eigenval(job_array(j,2):job_array(j,3),:) = single(dlmread(name));
    end
    % Write eigenvalue
    name = [o.pcadir,'/',p(idx).eigenval_name,'_',num2str(o.filtlist(i).filt_idx),'.csv'];
    csvwrite(name,eigenval);
end

% Update param file
update_pca_param(s,p(idx).rootdir, paramfilename,idx);

% Clear intermediate files
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenfactors_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenval_*']);
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/eigenvalprog_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/',p(idx).eigenval_name,'_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/wei_*']);
system(['rm -f ',p(idx).rootdir,'/',o.tempdir,'/timer_eigenval*']);


% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_eigenval']);
disp([s.nn,'PCA Eigenvalue calculation complete!!!']);


