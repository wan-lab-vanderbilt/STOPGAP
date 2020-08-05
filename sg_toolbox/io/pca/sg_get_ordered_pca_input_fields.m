function ordered_fields = sg_get_ordered_pca_input_fields()
%% sg_get_ordered_pca_input_fields
% Get ordered fields for PCA parameter files.
%
% WW 05-2019


%% Get fields
ordered_fields = {'completed', 'boo';
                  'pca_task', 'str';
                  'rootdir', 'str';
                  'tempdir', 'str';
                  'commdir', 'str';
                  'rawdir', 'str';
                  'refdir', 'str';
                  'maskdir', 'str';
                  'listdir', 'str';
                  'subtomodir', 'str';
                  'rvoldir', 'str';
                  'pcadir', 'str';
                  'metadir', 'str';
                  'iteration', 'num';
                  'motl_name', 'str';
                  'wedgelist_name', 'str';
                  'binning', 'num';
                  'ref_name', 'str';
                  'subtomo_name', 'str';
                  'mask_name', 'str';
                  'rvol_name', 'str';
                  'rwei_name', 'str';
                  'filtlist_name', 'str';
                  'ccmat_name', 'str';
                  'covar_name', 'str';
                  'data_type', 'str';
                  'n_eigs', 'num';
                  'eigenvol_name', 'str';
                  'eigenfac_name', 'str';
                  'eigenval_name', 'str';
                  'apply_laplacian', 'boo';
                  'noise_corr', 'boo';
                  'symmetry', 'str';
                  'fthresh', 'num';};
              
