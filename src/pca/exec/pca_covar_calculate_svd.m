function pca_covar_calculate_svd(p,o,s)
%% pca_covar_calculate_svd
% Calculate SVD on a covariance matrix to obtain the eigenvectors.
%
% WW 06-2019

%% Initialize
disp([s.nn,'Preparing to perform SVDs...']);

% Load real-space mask
mask = read_vol(s,p.rootdir,[o.maskdir,p.mask_name]);
m_idx = mask > 0;
clear mask

%% Calculate eigenvectors

for i = o.filt_jobs
    disp([s.nn,'Perofrming SVD on covariance-matrix ',num2str(i),'...']);
    
    
    % Read covariance matrix
    covar_name = [o.pcadir,p.covar_name,'_',num2str(o.filtlist(i).filt_idx),'.mrc'];
    covarmat = sg_mrcread([p.rootdir,'/',covar_name]);
    
    % Perform PCA
    if p.n_eigs <= o.n_subtomos;
        [U,S,V] = svd(covarmat,'econ');
    else
        [U,S,V] = svd(covarmat);
    end
    
    % Write eigenvectors
    disp([s.nn,'SVD complete!!! Writing eigenvectors...']);
    for j = 1:p.n_eigs
        
        % Initialize eigenvector
        evec = zeros([o.boxsize,o.boxsize,o.boxsize],'single');
        
        % Parse image data
        evec(m_idx) = U(:,j);
        
        % Normalize eigenvector
        evec(m_idx) = (evec(m_idx) - mean(evec(m_idx)))./std(evec(m_idx));
        
        % Write eigenvector
        ev_name = [o.pcadir,'/',p.eigenvol_name,'_',num2str(o.filtlist(i).filt_idx),'_',num2str(j),s.vol_ext];
        write_vol(s,o,p.rootdir,ev_name,evec);
        
    end
    
    
    % Write checkjob
    system(['touch ',p.rootdir,'/',o.commdir,'/sg_pca_svd_',num2str(i)]);
    
end
disp([s.nn,'All eigenvectors written!!!']);






