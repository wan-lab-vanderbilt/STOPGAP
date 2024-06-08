function sg_motl_score_clean(input_motl,output_motl,s_cut)
%% sg_motl_score_clean
% Remove overlapping points for each tomogram within a motivelist. Points
% are cleaned using a given distance threshold; within the threshold, the
% position with the highest score is kept. 
%
% WW 05-2024

% %% Inputs
% 
% % % Motivelist names
% input_motl = 'allmotl_tomo1_obj1_shift_7.star';
% output_motl = 'allmotl_tomo1_obj1_shift_dclean_7.star';
% 
% % Score cutoff
% s_cut = 0;


%% Intialize

% Read allmotl
allmotl = sg_motl_read2(input_motl);

% Clean by score
keep = allmotl.score >= s_cut;
new_motl = sg_motl_parse_type2(allmotl,keep);
disp([num2str(sum(keep)),' out of ',num2str(numel(allmotl.motl_idx)),' remaining...']);

% Write new motl
sg_motl_write2(output_motl,new_motl);





