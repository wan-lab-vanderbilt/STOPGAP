%% sg_pca_hierarchical_cluster_references
% A function for taking a set of class references and performing
% hierarchical clustering to determine identical classes.
%
% In cases with sparse clases, it may be useful to over-classify and use
% clustering to idenitfy like classes. 
%
% WW 06-2019

%% Inputs

% Root director
rootdir = '.';

% Iteration
iteration = 40;

% Motivelist name
motl_name = 'lists/allmotl_class';
motl_suffix = 'cluster';    % Suffix to add to output file
% Reference name
ref_name = 'ref/ref_rclass';

% Mask
mask_name = 'masks/full_mask.mrc';

% Bandpass filter
lp_rad = 15;
lp_sigma = 3;
hp_rad = 1;
hp_sigma = 2;


%% Initialize

% Read motivelist
motl = sg_motl_read([rootdir,'/',motl_name,'_',num2str(iteration),'.star']);
subtomos = unique([motl.subtomo_num]);
n_subtomos = numel(subtomos);
classes = unique([motl.class]);
n_classes = numel(classes);



% Read mask
mask = sg_mrcread([rootdir,'/',mask_name]);
boxsize = size(mask,1);
m_idx = mask > 0;
m_val = mask(m_idx);

% Generate filter
lowpass = sg_sphere(boxsize,lp_rad,lp_sigma);
hipass = sg_sphere(boxsize,hp_rad,hp_sigma);
bandpass = ifftshift(lowpass-hipass); % Bandpass filter


% Read in references
ref_cell = cell(n_classes,1);
filt_cell = cell(n_classes,1);
for i = 1:n_classes
    ref_cell{i} = sg_mrcread([rootdir,'/',ref_name,'_',num2str(iteration),'_',num2str(classes(i)),'.mrc']); % Read ref
    filt_cell{i} = real(ifftn(fftn(ref_cell{i}).*bandpass));                                                % Bandpass filter ref
%     filt_cell{i} = (filt_cell{i} - mean(filt_cell{i}(:)))./std(filt_cell{i}(:));                            % Normalize ref
end


% Calculate pairs
[pairs,idx] = sg_pca_determine_unique_pairs(n_classes);
n_pairs = size(pairs,1);

% CC array
cc_array = zeros(n_pairs,1);


%% Calcualte CCs


% Calculate pairwise CCs
for i = 1:n_pairs    
%     cc_array(i) = sg_pearson_correlation((filt_cell{pairs(i,1)}(m_idx).*m_val),(filt_cell{pairs(i,2)}(m_idx).*m_val));    
    cc_map = calculate_flcf(filt_cell{pairs(i,1)},mask,conj(fftn(filt_cell{pairs(i,1)})),conj(fftn(filt_cell{pairs(i,1)}.^2)));
    cc_array(i) = max(cc_map(:));
end

% Initialize CC-matrix
cc_mat = zeros(n_classes,n_classes,'single');

% Fill bottom half
cc_mat(idx) = cc_array;

% Mirror matrix and fill diagonal
cc_mat = cc_mat + rot90(fliplr(cc_mat),1) + eye([n_classes,n_classes],'single');

%% Hierarchical clustering

% Dissimilarity matrix
dis_mat = 1 - cc_mat;

% Compute linkage clustering
Z = linkage(dis_mat,'complete');

% Show dendrogram
dendrogram(Z)
dend = gcf;

 % Ask for input about clustering threshold
wait = 0;
while wait == 0;
    % Wait for user input
    assess_string = input('\nI demand the clustering threshold!!!\n','s'); 

    % Empty string
    if isempty(assess_string) 
        fprintf('I expect an answer!!! \n');        
    end

    % Check input is only digits
    isstr = isstrprop(assess_string, 'digit') + isstrprop(assess_string, 'punct') - isstrprop(assess_string,'wspace');
    if (sum(isstr) == numel(assess_string)) && (numel(assess_string) ~= 0)
        threshold = str2double(assess_string);
        wait = 1;
    else
        disp('This is unacceptable!!!')
        
    end
end

% Reset dendrogram
if ishandle(dend)
    close(dend)
end
dendrogram(Z,0,'ColorThreshold',threshold);

% Cluster!
T = cluster(Z,'cutoff',threshold,'criterion','distance');

% Assign new classes
new_class = zeros(n_subtomos,1);
for i = 1:n_classes
    c_idx = [motl.class] == classes(i);
    new_class(c_idx) = T(i);
end
motl = sg_motl_fill_field(motl,'class',new_class);

% Write ouptut
output_name = [rootdir,'/',motl_name,'_',motl_suffix,'_',num2str(iteration),'.star'];
sg_motl_write(output_name,motl);
 
n_clusters = numel(unique(T));
disp(['Number of otuput clusters: ',num2str(n_clusters)]);
% Print classes
for i = 1:n_clusters
    n = sum(new_class==i);
    disp(['Subtomos in cluster ',num2str(i),': ',num2str(n),' (',num2str(n*100/n_subtomos),'%)']);
end











