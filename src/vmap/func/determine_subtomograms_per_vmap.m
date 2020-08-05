function n_subtomos = determine_subtomograms_per_vmap(p,o,idx)
%% determine_subtomograms_per_vmap
% Determine the number of subtomograms in each variance map.
%
% WW 06-2019

%% Determine numbers

% Determine averaged entries in motivelist
motl_idx = ismember(o.allmotl.motl_idx,o.motl_idx); % Not redundant for multientry motivelists
n_motls = numel(motl_idx);

% Check score threshold
if sg_check_param(p(idx),'score_thresh')
    score_thresh = p(idx).score_thresh;
else
    score_thresh = 0;
end

% Determine requirements for averaging
switch o.motl_type
    
    case {1,2}
        
        
        % Parse thresholded scores
        score_idx = repmat(reshape((o.allmotl.score(motl_idx) >= score_thresh),1,o.n_motls),o.n_classes,1); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == repmat(reshape(o.allmotl.class(motl_idx),1,o.n_motls),o.n_classes,1); 
        
        
    case 3
       
                
        % Parse thresholded scores
        score_idx = reshape((o.allmotl.score(motl_idx) >= score_thresh),o.n_classes,o.n_motls); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == reshape(o.allmotl.class(motl_idx),o.n_classes,o.n_motls);
        
end


% Number of subtomos
n_subtomos = sum((score_idx & class_idx),2);

        
        
        
        
