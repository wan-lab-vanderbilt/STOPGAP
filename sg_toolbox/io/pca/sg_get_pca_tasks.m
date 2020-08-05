function tasks = sg_get_pca_tasks()
%% sg_get_pca_tasks
% Return a list of tasks for STOPGAP PCA.
%
% WW 05-2019

%% Return tasks

tasks = {'rot_vol';             % Pre-rotate volumes and wedge filters
        'calc_ccmat';           % Calculate CC-matrix
        'calc_covar';           % Calculate covariance matrix
        'calc_pca_ccmat';       % Calculate PCA from CC-matrix, generate eigenvolumes, calculate eigenvalues.
%        'calc_pca_covar';       % Calculate SVD from covariance matrix and calculate eigenvalues.
        };
    
    
