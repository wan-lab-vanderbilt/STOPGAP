%% sg_pca_kmeans_cluster
% Perform k-means clustering on a set of eigenvalues.
%
% WW 06-2019

%% Inputs

% Root director
rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/test_sg_0.7.1/tm_test/';

% Parameter file
paramfilename = 'params/pca_param.star';
param_idx = 9;


% Filters/Eigenvectors (column array with filter and eigenvector on each row.
vectors = [1,1];



% Number of classes
n_classes = 4;

% Output suffix
suffix = 'ccmat';


%% Initialize

% Read param
p = sg_read_pca_param(rootdir,paramfilename);

% Get default settings
s = struct();
s = sg_get_pca_settings(s,p(param_idx).rootdir,'pca_settings.txt');


% Initialize struct array to hold objects
o = struct();
o = sg_parse_pca_directories(p,o,s,param_idx);

% Read motivelist
motl = sg_motl_read2([p(param_idx).rootdir,'/',o.listdir,'/',p(param_idx).motl_name,'_',num2str(p(param_idx).iteration),'.star']);
n_subtomos = numel(unique(motl.subtomo_num));

% Read in filter list
o = load_filter_list(p,o,s,param_idx);

% Load Eigenvalues
input_eigenval = zeros(n_subtomos,p(param_idx).n_eigs,o.n_filt);
for i = 1:o.n_filt
    name = [o.pcadir,'/',p(param_idx).eigenval_name,'_',num2str(o.flist(i).filt_idx),'.csv'];
    input_eigenval(:,:,i) = single(dlmread([p(param_idx).rootdir,'/',name]));
end

% Parse eigenvalues of interest
n_vec = size(vectors,1);
eigenval = zeros(n_subtomos,n_vec,'single');
for i = 1:n_vec
    eigenval(:,i) = input_eigenval(:,vectors(i,2),vectors(i,1));
end


%% Perform K-means clustering


% Calculate kmeans
[class_idx,~,sumd] = kmeans(eigenval,n_classes,'replicates',5);

% Assign classes
motl.class = class_idx;

% Print classes
for i = 1:n_classes
    n = sum(class_idx==i);
    disp(['Subtomos in class ',num2str(i),': ',num2str(n),' (',num2str(n*100/n_subtomos),'%)']);
end

% Write output
motl_name = [o.listdir,'/',p(param_idx).motl_name,'_',suffix,'_',num2str(p(param_idx).iteration),'.star'];
sg_motl_write2([p(param_idx).rootdir,motl_name],motl);



















