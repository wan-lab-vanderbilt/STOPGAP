function pca_assemble_ccmatrix(p,o,s,idx)
%% pca_assemble_ccmatrix
% Assemble partial CC-arrays into complete CC-matrices.
%
% WW 06-2019


%% Initialize
disp([s.nn,'Assembling CC-matrices...']);

% Take lower half of identity matrix
mat = tril(true(o.n_subtomos,o.n_subtomos),-1);

% Find indices of matrix positions
lower_idx = find(mat);
n_pairs = numel(lower_idx);
clear mat

% Get job arrays
[~,~,job_array] = job_start_end(n_pairs,o.n_cores,1);



%% Generate CC-matrices

% Loop through filters
for i = o.filt_jobs
    
    % Concatenate CC-array
    cc_array = zeros(n_pairs,1,'single');
    for j = 1:o.n_cores
        cc_array_name = [o.tempdir,'/ccarray_',num2str(j),'_',num2str(i),'.csv'];
        cc_array(job_array(j,2):job_array(j,3),1) = dlmread([p(idx).rootdir,'/',cc_array_name]);
    end
    
    % Initialize CC-matrix
    cc_mat = zeros(o.n_subtomos,o.n_subtomos,'single');
    
    % Fill bottom half
    cc_mat(lower_idx) = cc_array;
    
    % Mirror matrix and fill diagonal
    cc_mat = cc_mat + rot90(fliplr(cc_mat),1) + eye([o.n_subtomos,o.n_subtomos],'single');
    
    % Write CC-matrix
    cc_mat_name = [o.pcadir,'/',p(idx).ccmat_name,'_',num2str(p(idx).iteration),'_',num2str(o.filtlist(i).filt_idx),'.mrc'];
    sg_mrcwrite([p(idx).rootdir,'/',cc_mat_name],cc_mat);
    
    % Clear arrays
    clear cc_array cc_mat

    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_ccmatrix_',num2str(i)]);
    disp([s.nn,num2str(i),' out of ',num2str(o.n_filt),' CC-matrices assembled!!!']);

end




    

