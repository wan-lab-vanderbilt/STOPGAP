function sg_motl_flip_polarity_by_list(input_motl,output_motl,flip_list)
%% sg_motl_flip_polarity_by_list
% Read in a flip_list, a Nx3 .csv file with columns: 1-tomo_num, 2-object,
% 3-flip. For each object that is flipped, the phi angle is incremented by
% 180.
%
% Objects absent from the flip list are omitted in the output motl.
%
% WW 11-2018

% input_motl = 'allmotl_classes_11.star';
% output_motl = 'allmotl_classes_pflip_11.star';
% flip_list = 'class_polarity2.csv';


%% Initialize

% Read input motl
motl = sg_motl_read(input_motl);

% Read fliplist
flist = dlmread(flip_list);
n_obj = size(flist,1);


% Initialize new motl
motl_cell = cell(n_obj,1);

%% Flip objects
disp('Flipping objects...');

for i = 1:size(flist,1)
    
    % Parse object motl
    tomo_idx = [motl.tomo_num] == flist(i,1);
    obj_idx = [motl.object] == flist(i,2);
    idx = tomo_idx & obj_idx;
    temp_motl = motl(idx);
    
    % Check for flipping
    if flist(i,3) ~= 1
        temp_phi = [temp_motl.phi] + 180;
        temp_motl = sg_motl_fill_field(temp_motl,'phi',temp_phi);
    end    
    
    % Store motl
    motl_cell{i} = temp_motl;
    
end

% Concatenate new motl
new_motl = cat(1,motl_cell{:});

% Write output
sg_motl_write(output_motl,new_motl);


