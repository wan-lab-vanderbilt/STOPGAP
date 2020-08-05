function sg_motl_intiailize_random_subset_classes(motl_name,n_classes,n_subtomos,output_name)
%% sg_motl_intiailize_random_subset_classes
% Generate a set of classes (n_classes) from random subsets of an input 
% motivelist. The number of subtomograms (n_subtomos) for each class can be
% given as a number of subtomograms or as a fraction, which will be
% interpreted as a percentage of the motivelist. 
%
% NOTE: Some subtomograms will likely appear in more than one class. As
% such, you probably want to use this script to seed random classes but NOT
% to generate a motivelist for classification. 
%
% WW 09-2019

%% Check check

% Read motivelist
motl = sg_motl_read2(motl_name);

% Check type
if sg_motl_check_type(motl) == 3
    motl = sg_motl_multientry_to_singlentry(motl);
end

%% Generate randomized indices


% Number of motivelist entires
n_motl = numel(motl.motl_idx);

% Check number of subtomograms
if n_subtomos < 1
    n_subtomos = round(n_motl*n_subtomos);
end

% Generate randomized indices
rand_cell = cell(n_classes,1);
for i = 1:n_classes
    temp_rand = randperm(n_motl)';
    rand_cell{i} = temp_rand(1:n_subtomos);
end
rand_idx = cat(1,rand_cell{:});

%% Generate new motlivelist

% Get motl fields
fields = sg_get_motl_fields;
n_fields = size(fields,1);

% Initialize new motivelist
new_motl = struct();

% Fill struct
for i = 1:n_fields
    new_motl.(fields{i,1}) = motl.(fields{i,1})(rand_idx);
end

% Renumber motl indices
new_motl.motl_idx = (1:numel(new_motl.motl_idx))';

% Apply classes
new_motl.class = int32(reshape(repmat(1:n_classes,n_subtomos,1),[],1));

% Write output
sg_motl_write2(output_name,new_motl);









