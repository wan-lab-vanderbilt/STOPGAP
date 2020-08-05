function pca_assemble_covariance_matrix(p,o,s,idx)
%% pca_assemble_covariance_matrix
% Assemble partial CC-arrays into complete CC-matrices.
%
% WW 06-2019


%% Initialize
disp([s.nn,'Assembling covariance-matrices...']);

% Load real-space mask
mask = read_vol(s,p(idx).rootdir,[o.maskdir,p(idx).mask_name]);
m_idx = mask > 0;
n_vox = sum(m_idx(:));
clear mask m_idx

% Get job arrays
[~,~,job_array] = job_start_end(o.n_subtomos,o.n_cores,1);




%% Generate covariance matrices

% Loop through filters
for i = o.filt_jobs
    
    % Initialize covariance arrays
    covar = zeros(n_vox,o.n_subtomos,'single');
    
    % Fill array
    for j = 1:o.n_cores
        covar_name = [o.tempdir,'/',p(idx).covar_name,'_',num2str(j),'_',num2str(i),s.vol_ext];
        covar(:,job_array(j,2):job_array(j,3)) = read_vol(s,p(idx).rootdir,covar_name);
    end
    
    
    % Write covariance-matrix
    covar_name = [o.pcadir,'/',p(idx).covar_name,'_',num2str(p(idx).iteration),'_',num2str(o.flist(i).filt_idx),s.vol_ext];
    sg_mrcwrite([p(idx).rootdir,'/',covar_name],covar);
    
    % Clear arrays
    clear covarj

    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_covarmat_',num2str(i)]);
    disp([s.nn,num2str(i),' out of ',num2str(o.n_filt),' covariance matrices assembled!!!']);

end




    

