%% sg_motl_distance_clean
% Remove overlapping points for each tomogram within a motivelist. Points
% are cleaned using a given distance threshold; within the threshold, the
% position with the highest score is kept. 
%
% WW 08-2018

%% Inputs

% Motivelist names
input_motl = 'allmotl_pdb_1.star';
output_motl = 'allmotl_pdb_dclean4_1.star';

% Distance cutoff (pixels)
d_cut = 4;

% Score cutoff
s_cut = 0.4;


%% Intialize

% Read allmotl
allmotl = sg_motl_read2(input_motl);
n_motls = numel(allmotl.subtomo_num);

% Parse tomograms
tomos = unique(allmotl.tomo_num);
n_tomos = numel(tomos);

% Clean by score
keep = false(n_motls,1);

%% Loop through and clean

for i = 1:n_tomos
    
    % Parse tomogram
    tomo_idx = find(allmotl.tomo_num == tomos(i));
    n_temp_motl = numel(tomo_idx);
    
    % Parse positions
    pos = cat(1,(allmotl.orig_x(tomo_idx) + allmotl.x_shift(tomo_idx))',...
                (allmotl.orig_y(tomo_idx) + allmotl.y_shift(tomo_idx))',...
                (allmotl.orig_z(tomo_idx) + allmotl.z_shift(tomo_idx))');
            
    % Parse scores
    temp_scores = allmotl.score(tomo_idx);
    
    % Sort scores
    [~,sort_idx] = sort(temp_scores);
            
    % Temporary keep index
    temp_keep = true(n_temp_motl,1);
    temp_keep(temp_scores < s_cut) = false;
    
    % Loop through in order of score
    for j = 1:n_temp_motl
        
        if temp_keep(sort_idx(j))
            
            % Calculate distances
            dist = sg_pairwise_dist(pos(:,sort_idx(j)),pos);
            
            % Find cutoff
            d_cut_idx = dist < d_cut;
            
            % Keep current entry
            d_cut_idx(sort_idx(j)) = false;
            
            % Remove other entries
            temp_keep(d_cut_idx) = false;
                       
        end
    end
    
    % Add entries to main list
    keep(tomo_idx) = temp_keep;
    
end


%% Clean fields

% Parse fields
fields = fieldnames(allmotl);
n_fields = numel(fields);

% Loop through fields
for i = 1:n_fields
    allmotl.(fields{i}) = allmotl.(fields{i})(keep);
end

% Write output
sg_motl_write2(output_motl,allmotl);

% Display output
disp([num2str(numel(allmotl.subtomo_num)),' out of ',num2str(n_motls),' remaining...']);


    
    
    
    
            
