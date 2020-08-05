function motl = sg_sort_motl2(motl)
%% sg_sort_motl2
% A function to sort a motl struct array. The proper soring is to sort
% first by the motl_idx, then by the class.
%
% WW 06-2019

%% Sort!!!

% Sort by motl_idx and class
sort_array = cat(2,motl.motl_idx,motl.class);

% Sorting index
[~,sort_idx] = sortrows(sort_array,[1,2]);

% Sort each field
fields = fieldnames(motl);
for i = 1:numel(fields)
    motl.(fields{i}) = motl.(fields{i})(sort_idx);
end


