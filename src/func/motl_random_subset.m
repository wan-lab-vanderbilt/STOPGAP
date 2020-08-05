
function o = motl_random_subset(p,o,s,idx)
%% motl_random_subset
% A function to pseduo randomly generate a subset of motivelist entries.
%
% WW 06-2019

%% Generate random subset
disp([s.nn,'Generating random subset of motivelist entries...']);

% New number of subtomograms
o.n_rand_motls = round_to_even(o.n_motls*(p(idx).subset/100));


switch o.halfset_mode
    
    case 'single'
        
        % Generate randomized indices
        rng(o.rseed,'twister');
        temp_idx = randperm(o.n_motls);
        r_idx = sort(temp_idx(1:o.n_rand_motl));
        
        
    case 'split'
        
        % Parse halfset for each entry
        switch o.motl_type
            case {1,2}
                temp_a_idx = strcmp(o.allmotl.halfset,'A');               
            case 3
                temp_a_idx = strcmp(o.allmotl.halfset(1:o.n_classes:o.n_motls),'A');
        end
        a_idx = find(temp_a_idx);
        b_idx = find(~temp_a_idx);
                
        % Random subset of A
        rng(o.rseed/65,'twister');
        r_a_idx = randperm(numel(a_idx));
        rng(o.rseed/66,'twister');
        r_b_idx = randperm(numel(b_idx));
        r_idx = sort([a_idx(r_a_idx(1:o.n_rand_motls/2));b_idx(r_b_idx(1:o.n_rand_motls/2))]);
                              
        
end

% Parse randomized subtomos
o.rand_subset_idx = r_idx;
o.rand_motl = o.motl_idx(r_idx);


