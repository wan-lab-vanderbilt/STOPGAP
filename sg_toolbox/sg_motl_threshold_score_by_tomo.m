%% sg_motl_threshold_score_by_tomo
% A function to apply a per-tomogram score thresholding. Scoring functions
% are often defocus-dependent, making per-tomogram thresholding better than
% using a single score for the whole dataset.
%
% Input tomogram/score array is expected to be a .csv column vector with
% columns [tomo_num],[score]. Scores < score are removed.
%
% WW 08-2018

%% Inputs

% Motivelist names
input_name = 'allmotl_dclean4_3.star';
output_name = 'allmotl_dclean4_ccclean_3.star';

% Score list
slist_name = 'score_list.csv';


%% Initialize

% Read motivelist
allmotl = sg_motl_read(input_name);

% Read score list
slist = csvread(slist_name);

% Parse tomograms
tomos = unique([allmotl.tomo_num]);
n_tomos = numel(tomos);

% Check tomograms
tomo_test = intersect(tomos,slist(:,1));
if numel(tomo_test) ~= n_tomos
    error('ACHTUNG!!!! Tomograms in motivelist do not match tomograms in score list!!!');
end

% Cleaned tomogram motivelists
clean_cell = cell(n_tomos,1);


%% Clean tomograms

% Clean tomograms
for i = 1:n_tomos
    
    % Tomogram indices
    tomo_idx = [allmotl.tomo_num] == tomos(i);
    
    % Find score row
    score_row = slist(:,1) == tomos(i);
    
    % Score indices
    score_idx = [allmotl.score] >= slist(score_row,2);
    
    % Store cleaned motl
    clean_cell{i} = allmotl(tomo_idx & score_idx);
    
end

% Concatenate outputs
clean_motl = cat(1,clean_cell{:});

% Write output
sg_motl_write(output_name,clean_motl);

    
    






