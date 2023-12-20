function obj_table = sg_object_list2(motl)
%% sg_object_list2
% Generate list of objects and tomograms from a type2 motivelist.
%
% WW 08-2023

%% Make list

% Parse tomograms
tomos = unique([motl.tomo_num]);
n_tomos = numel(tomos);

% Determine objects per tomogram
obj_per_tomo = cell(n_tomos,2);
for i = 1:n_tomos
    tomo_idx = motl.tomo_num==tomos(i);
    obj_per_tomo{i,2} = unique(motl.object(tomo_idx));
    obj_per_tomo{i,1} = repmat(tomos(i),[1,numel(obj_per_tomo{i,2})]);
end


obj_table = cat(1,cat(2,obj_per_tomo{:,1}),cat(2,obj_per_tomo{:,2}));
