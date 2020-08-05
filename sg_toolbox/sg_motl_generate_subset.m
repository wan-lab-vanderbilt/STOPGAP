function sg_motl_generate_subset(input_name,output_name,subset_type,subset_unit,subset_size)
%% sg_motl_generate_subset
% Generate a subset of a motivelist. 'subset_type' defines what to generate
% subsets of; 'tomo' for tomogram subsets and 'object' for object subsets.
% The 'subset_unit' parameter defines what units to produce the subset it;
% options are 'percent' or 'subtomo'. 'subset_size' defines the size with
% respect to the subset unit. 
%
% WW 11-2018


%% Initialize

% Read motl
motl = sg_motl_read(input_name);

% Parse set indices
switch subset_type
    case 'tomo'
        % Parse tomograms
        tomos = unique([motl.tomo_num]);
        n_sets = numel(tomos);
        
        % Generate list of set indices
        sets = cell(n_sets,1);
        for i = 1:n_sets
            sets{i} = find([motl.tomo_num] == tomos(i));
        end
        
    case 'object'
        
        % Generate object table
        obj_table = sg_motl_object_table(motl);
        n_sets = size(obj_table,1);
        
        % Generate list of set indices
        sets = cell(n_sets,1);
        for i = 1:n_sets
            tomo_idx = [motl.tomo_num] == obj_table(i,1);
            obj_idx = [motl.object] == obj_table(i,2);
            sets{i} = find(tomo_idx & obj_idx);
        end
        
end

%% Generate subsetys

% Subset indices
subset = cell(n_sets,1);

for i = 1:n_sets
    
    
    
    % Number of motls in subset
    n_motls = numel(sets{i});
    
    % Determine subset size
    switch subset_unit
        
        case 'percent'
            n_subset = round(n_motls*(subset_size/100));
            
        case 'subtomo'
            n_subset = subset_size;
    end
       
    % Generate random subset
    r_idx = randperm(n_motls);
    subset{i} = sets{i}(r_idx(1:n_subset));
            
end

% Subset index
subset_idx = [subset{:}];

% New motl
new_motl = motl(subset_idx);
            
% Write motl
sg_motl_write(output_name,new_motl);




