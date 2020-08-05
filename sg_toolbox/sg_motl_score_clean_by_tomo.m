function sg_motl_score_clean_by_tomo(input_motl,output_motl,score_list)
%% sg_motl_score_clean_by_tomo
% Remove underscoring subtomograms from a motivelist, using score cutoffs
% per tomogram. The score list is a Nx2 vector where column 1 contains the
% tomogram numbers and column 2 contains the score cutoffs. Subtomograms
% with scores >= the cutoffs are kept. 
%
% WW 09-2018

%% Read inputs

% Read input motl
motl = sg_motl_read(input_motl);
tomos = unique([motl.tomo_num]);
n_tomos = numel(tomos);

% Read score list
cutoff_list = dlmread(score_list);

% Keep cell
keep_cell = cell(n_tomos,1);



%% Clean by tomogram

for i = 1:n_tomos
    
    % Find cutoff
    c_idx = cutoff_list(:,1) == tomos(i);
    cutoff = cutoff_list(c_idx,2);
    
    % Find tomogram index
    tomo_idx = [motl.tomo_num] == tomos(i);
    
    % Parse scores
    tomo_scores = [motl(tomo_idx).score];
    
    % Threshold scores
    keep_cell{i} = tomo_scores >= cutoff;
    
end

% Clean motl
keep = [keep_cell{:}];    
new_motl = motl(keep);

% Write output
sg_motl_write(output_motl,new_motl);
disp([num2str(sum(keep)),' out of ',num2str(numel(motl)),' remaining...']);
