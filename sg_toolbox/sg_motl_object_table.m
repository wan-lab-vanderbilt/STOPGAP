function obj_table = sg_motl_object_table(motl)
%% sg_motl_object_table
% Generate a table containing the tomogram numbers and objects for each
% object in a motivelist.
%
% WW 11-2018

%% Generate tables

% Parse tomograms
tomos = single(unique([motl.tomo_num]));
n_tomos = numel(tomos);

% Cell array to hold tomogram objects
tomo_cell = cell(n_tomos,1);

% Parse objects
for i = 1:n_tomos
    
    % Parse tomogram
    tomo_idx = [motl.tomo_num] == tomos(i);
    temp_motl = motl(tomo_idx);
    
    % Parse objects
    temp_obj = unique([temp_motl.object]);
    n_temp_obj = numel(temp_obj);
    
    % Object table
    temp_tbl = ones(n_temp_obj,2).*tomos(i);
    temp_tbl(:,2) = temp_obj;
    
    % Store partial table
    tomo_cell{i} = temp_tbl;
    
end

% Concatenate table
obj_table = [tomo_cell{:}];
n_obj = size(obj_table,1);


% Determine counts per object
counts = zeros(n_obj,1);
for i = 1:n_obj
    tomo_idx = [motl.tomo_num] == obj_table(i,1);
    obj_idx = [motl.object] == obj_table(i,2);
    counts(i) = sum(tomo_idx & obj_idx);
end
obj_table = cat(2,obj_table,counts);

