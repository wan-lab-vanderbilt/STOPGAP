function n_subtomos = determine_subtomograms_per_parallel_ps(p,o,idx)
%% determine_subtomograms_per_parallel_ps
% Determine the number of subtomograms in each parallel power spectrum.
%
% WW 10-2022

%% Determine numbers

% Determine processed entries in motivelist
motl_idx = ismember(o.allmotl.motl_idx,o.motl_idx); % Not redundant for multientry motivelists
n_motls = o.n_motls;


% Check score threshold
if sg_check_param(p(idx),'score_thresh')
    score_thresh = p(idx).score_thresh;
else
    score_thresh = 0;
end

% Determine requirements for averaging
switch sg_motl_check_type(o.allmotl,2)
    
    case {1,2}
        
        % Parse thresholded scores
        score_idx = repmat(reshape((o.allmotl.score(motl_idx) >= score_thresh),1,n_motls),o.n_classes,1); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == repmat(reshape(o.allmotl.class(motl_idx),1,n_motls),o.n_classes,1); 
        
        
    case 3
                
        % Parse thresholded scores
        score_idx = reshape((o.allmotl.score(motl_idx) >= score_thresh),o.n_classes,n_motls); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == reshape(o.allmotl.class(motl_idx),o.n_classes,n_motls);
        
end


% Sum halfset A
n_subtomos = sum((score_idx & class_idx),2);

        
        
        
        
