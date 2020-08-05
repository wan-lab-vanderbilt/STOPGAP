function pca_ccmat_calculate_eigenfactors(p,o,s,idx)
%% pca_ccmat_calculate_eigenfactors
% Calculate eigenfactors from CC-matrices.
%
% WW 06-2019

%% Calculate eigenfactors

for i = o.filt_jobs
    disp([s.nn,'Calculating Eigenfactors from CC-matrix ',num2str(i),'...']);
    
    
    % Read CC-matrix
    cc_mat_name = [o.pcadir,'/',p(idx).ccmat_name,'_',num2str(p(idx).iteration),'_',num2str(o.filtlist(i).filt_idx),'.mrc'];
    ccmatrix = sg_mrcread([p(idx).rootdir,'/',cc_mat_name]);
    
    % Perform PCA
    [eigenfactors,~] = eigs(double(ccmatrix),p(idx).n_eigs,'LM');
    
    % Write eigenfactors
    ef_name = [o.pcadir,'/',p(idx).eigenfac_name,'_',num2str(o.filtlist(i).filt_idx),'.csv'];
    dlmwrite([p(idx).rootdir,'/',ef_name],eigenfactors);
    
    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenfactors_',num2str(i)]);
    
end






