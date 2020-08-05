function sg_motl_flip_polarity(input_motl,unflip_motl,flip_motl,output_motl)
%% sg_motl_flip_polarity
% Compare scores between flipped and unflipped subets, determine flipping,
% and apply to a full motivelist.
%
% WW 11-2018

input_motl = 'allmotl_1.star';
unflip_motl = 'allmotl_subset_2.star';
flip_motl = 'allmotl_subset_flip_2.star';
output_motl = 'allmotl_sorted_1.star';


%% Initialize

% Read input motl
allmotl = sg_motl_read(input_motl);

% Read unflipped motl
unflip = sg_motl_read(unflip_motl);

% Read flipped motl
flip = sg_motl_read(flip_motl);


% Get object table
obj_table = sg_motl_object_table(allmotl);
n_obj = size(obj_table,1);

% Initialze flip array
flip_array = zeros(n_obj,2);


%% Determine flipping

for i = 1:n_obj
    
    % Parse object
    tomo_idx = [unflip.tomo_num] == obj_table(i,1);
    obj_idx = [unflip.object] == obj_table(i,2);
    idx = tomo_idx & obj_idx;
    n_motl = sum(idx);
    
    % Parse scores
    unflip_score = [unflip(idx).score];
    flip_score = [flip(idx).score];
    
    % Check for flipping
    flip_check = flip_score > unflip_score;
    flip_pct = sum(flip_check)/n_motl;
    
    % Check for flip
    if flip_pct > 0.5
        flip_array(i,1) = 1;
        flip_array(i,2) = flip_pct;
    else
        flip_array(i,2) = 1-flip_pct;
    end
    
end

%% Flip objects

sort_motl = allmotl;

for i = 1:n_obj
    
    % Flip motl
    if flip_array(i,1) == 1
        
        % Parse object
        tomo_idx = [allmotl.tomo_num] == obj_table(i,1);
        obj_idx = [allmotl.object] == obj_table(i,2);
        idx = tomo_idx & obj_idx;
        
        % Flip object
        temp_phi = [sort_motl(idx).phi];
        sort_motl(idx) = sg_motl_fill_field(sort_motl(idx),'phi',temp_phi);
        
    end
end

sg_motl_write(output_motl,sort_motl);        

    


