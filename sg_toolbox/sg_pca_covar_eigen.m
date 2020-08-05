%% sg_pca_covar_eigen
% Calculate eigenvolumes and eigenvalues from covariance matrix.
%
% WW 07-2019

%% Inputs

% Root director
rootdir = '/fs/pool/pool-plitzko/will_wan/test_sg_0.7.1/tm_test/';

% Parameter file
paramfilename = 'params/pca_param.star';
param_idx = 5;  % Index in paramfile to pull parameters from

pixelsize = 2.62*4;

% Eigenvector params
add_ref = false;     % Add eigenvolume to reference (can help interpretation of eigenvectors of difference data)



%% Initialize

% Read param
p = sg_read_pca_param(rootdir,paramfilename);

% Get default settings
se = struct();
se = sg_get_pca_settings(se,p(param_idx).rootdir,'pca_settings.txt');


% Initialize struct array to hold objects
o = struct();
o = sg_parse_pca_directories(p,o,se,param_idx);

% Read motivelist
motl = sg_motl_read2([p(param_idx).rootdir,'/',o.listdir,'/',p(param_idx).motl_name,'_',num2str(p(param_idx).iteration),'.star']);
n_subtomos = numel(unique(motl.subtomo_num));

% Read in filter list
o = load_filter_list(p,o,se,param_idx);


% Read mask
mask = sg_volume_read([p(param_idx).rootdir,'/',o.maskdir,'/',p(param_idx).mask_name]);
m_idx = mask > 0;
m_val = mask(m_idx);
o.boxsize = size(mask);


% Read reference
if add_ref
    
    % Read reference
    ref_name = [o.refdir,'/',p(param_idx).ref_name,'_',num2str(p(param_idx).iteration),se.vol_ext];
    ref = sg_volume_read([p(param_idx).rootdir,'/',ref_name]);
    
    % Normalize under mask
    ref = (ref - mean(ref(m_idx).*m_val))./std(ref(m_idx).*m_val);
    
end




%% Calculate SVD

for i = 1:o.n_filt
    
    % Load covariance matrix
    disp(['Loading covariance matrix ',num2str(o.flist(i).filt_idx),'...']);
    covar_name = [o.pcadir,'/',p(param_idx).covar_name,'_',num2str(p(param_idx).iteration),'_',num2str(o.flist(i).filt_idx),se.vol_ext];
    covar = sg_volume_read([p(param_idx).rootdir,'/',covar_name]);
    
    
    
    % Calculate SVD 
    disp('Performing SVD...');
    t = tic;
    [u,s,v] = svd(covar);
    time = toc(t);
    disp(['SVD performed in: ',num2str(time),' s']);
    
    
    
    % Write eigenvolumes
    disp('Writing eigenvolumes...');
    for j = 1:p(param_idx).n_eigs
        
        % Normalize eigenvolume
        vol = zeros(o.boxsize,'single');
        vol(m_idx) = u(:,j);
        vol(m_idx) = (vol(m_idx)-mean(vol(m_idx).*m_val))./std(vol(m_idx).*m_val);

        % Apply ref
        if add_ref
            vol = vol + ref;
        end
        
        % Write eigenvolume
        eigvol_name = [o.pcadir,'/',p(param_idx).eigenvol_name,'_',num2str(o.flist(i).filt_idx),'_',num2str(j),se.vol_ext];
        sg_mrcwrite([p(param_idx).rootdir,'/',eigvol_name],vol,[],'pixelsize',pixelsize);
        
    end

    
    % Calculate eigenvalues
    disp('Writing eigenvalues...');
    coeff = s*v'; 
    eigenval = coeff(1:p(param_idx).n_eigs,:)';
    
    % Write eigenvalues
    eigval_name = [o.pcadir,'/',p(param_idx).eigenval_name,'_',num2str(o.flist(i).filt_idx),'.csv'];
    csvwrite([p(param_idx).rootdir,eigval_name],eigenval);
    
    
end
    










