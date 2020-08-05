%% sg_motl_distance_clean_xyz
% Remove overlapping points for each tomogram within a motivelist. Points
% are cleaned using a given distance threshold; within the threshold, the
% position with the highest score is kept. 
%
% WW 08-2018

%% Inputs

% Motivelist names
input_motl = 'allmotl_2.star';
output_motl = 'allmotl_dclean_2.star';

% Distance cutoff (pixels)
d_cut = [5,5,20];

% Score cutoff
s_cut = 0;


%% Intialize

% Read allmotl
allmotl = sg_motl_read(input_motl);
n_motls = numel(allmotl);

% Parse tomograms
tomos = unique([allmotl.tomo_num]);
n_tomos = numel(tomos);

% Clean by score
motl_cell = cell(n_tomos,1);


%% Perform distance cleaning

for i = 1:n_tomos        
    disp(['Cleaning tomogram ',num2str(i),' of ',num2str(n_tomos),'..']);
    
    
    % Parse positions from tomograms
    tomo_idx = [allmotl.tomo_num] == tomos(i);
    temp_motl = allmotl(tomo_idx);
    n_pos = sum(tomo_idx);
    pos = zeros(3,n_pos);
    pos(1,:) = [temp_motl.orig_x] + [temp_motl.x_shift];
    pos(2,:) = [temp_motl.orig_y] + [temp_motl.y_shift];
    pos(3,:) = [temp_motl.orig_z] + [temp_motl.z_shift];
    [~,score_idx] = sort([temp_motl.score],'descend');
    
    
    % Clean by score
    keep_idx = [temp_motl.score] >= s_cut;
    
    
    % Loop through each motl
    for j = score_idx

        % Perform search only on motls not removed yet
        if keep_idx(j)

            % Generate rotation matrix
            rmat = sg_euler2matrix(-temp_motl(j).psi,-temp_motl(j).phi,-temp_motl(j).the);
            
            % Shift and rotate positions
            r_pos = abs(rmat*(pos - repmat(pos(:,j),1,numel(temp_motl))));  % Absolute value for cutting step
            
            % Cut
            cut_idx = (r_pos(1,:) > 0) & (r_pos(1,:) < d_cut(1));
            cut_idx = cut_idx & (r_pos(2,:) > 0) & (r_pos(2,:) < d_cut(2));
            cut_idx = cut_idx & (r_pos(3,:) > 0) & (r_pos(3,:) < d_cut(3));
            keep_idx(cut_idx) = false;
            

        end                
    end
    
    % Store keep_idx
    motl_cell{i} = temp_motl(keep_idx);
    
%     sg_motl_write(['split16/cleanmotl_',num2str(tomos(i)),'.star'],temp_motl(keep_idx));
    
end


% Full keep index
% keep = [motl_cell{:}];

% New motl
% new_allmotl = allmotl(keep);
new_allmotl = cat(1,motl_cell{:});

% Write output
sg_motl_write(output_motl,new_allmotl);
disp([num2str(numel(new_allmotl)),' out of ',num2str(n_motls),' remaining...']);    
