function splitmotl = fill_splitmotl(splitmotl,ali,sm_idx)
%% fill_splitmotl
% Fill splitmotl array with top scoring entries from the ali array. 
%
% WW 06-2019

%% Fill splitmotl

% Number of motl entries
n_entry = size(ali,2);

% Loop through entries
for i = 1:n_entry
    
    % Find top score
    [~,max_idx] = max([ali(:,i).score]);
    
    % Fill fields
    splitmotl.x_shift(sm_idx) = ali(max_idx,i).new_shift(1);
    splitmotl.y_shift(sm_idx) = ali(max_idx,i).new_shift(2);
    splitmotl.z_shift(sm_idx) = ali(max_idx,i).new_shift(3);
    splitmotl.phi(sm_idx) = ali(max_idx,i).phi;
    splitmotl.psi(sm_idx) = ali(max_idx,i).psi;
    splitmotl.the(sm_idx) = ali(max_idx,i).the;
    splitmotl.score(sm_idx) = ali(max_idx,i).score;
    splitmotl.class(sm_idx) = ali(max_idx,i).class;
    
end
    

