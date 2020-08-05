function single_motl = sg_motl_multientry_to_singlentry(multi_motl)
%% sg_motl_multientry_to_singlentry
% Convert a multi-entry motivelist to a single-entry motivelist.
% This scripts picks the top scoring class for each motivelist and discards
% all other data.
%
% Input is either a motivelist or the name of a motivelist. 
%
% WW 09-2019

%% Check check

if ischar(multi_motl)
    multi_motl = sg_motl_read2(multi_motl);
else
    % Check read type
    read_type = sg_motl_check_read_type(multi_motl);
    if read_type == 1
        multi_motl = sg_motl_convert_type1_to_type2(multi_motl);
    end
end

% Check sorting
multi_motl = sg_sort_motl2(multi_motl);

%% Find top classes

% Motivelist entires
motl_idx = unqiue(motl.motl_idx);
n_motls = numel(motl_idx);

% Number of classes
classes = unique(motl.class);
n_classes = numel(classes);

% Parse scores
scores = reshape(motl.score,n_classes,n_motls);

% Top score indices
[~,top_idx] = max(scores,[],1);

% Space indices to full motivelist
top_idx = top_idx + ((0:n_motls-1) * n_classes);

% Parse motivelist
single_motl = sg_motl_parse_type2(multi_motl,top_idx);


