function motl_type = sg_motl_get_type(motl)
%% get_motivelist_type
% Check for single-entry or multi-entry motivelist. Multi-entry is a
% motivelist where all subtomograms have an entry for all classes; all
% others are considered single-entry.
%
% WW 11-2018

%% Determine type

% Determine classes
classes = unique([motl.class]);
n_classes = numel(classes);

% Return for 1 class
if n_classes == 1
    motl_type = 'single';
    return
end

% Determine number of subtomograms
subtomos = unique([motl.subtomo_num]);
n_subtomos = numel(subtomos);

% Number of entries in motivelist
n_motl = numel(motl);

% Check for correct number of motls given classes
if n_motl ~= (n_subtomos*n_classes)
    motl_type ='single';
    return
end

% Parse subtomo numbers and class numbers
subtomo_class = cat(2,[motl.subtomo_num]',[motl.class]');
subtomo_class = sortrows(subtomo_class,[1,2]);

% Check for correct classes per motl
class_array = reshape(subtomo_class(:,2),[n_classes,n_subtomos]);
check_array = repmat(classes(:),[1,n_subtomos]);
check = class_array == check_array;
if sum(check(:)) ~= n_motl
    motl_type = 'single';
else
    motl_type = 'multi';
end





