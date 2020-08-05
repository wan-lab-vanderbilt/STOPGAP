function n_subtomos = determine_subtomograms_per_average(p,o,idx)
%% determine_subtomograms_per_average
% Determine the number of subtomograms in each average for final averaging.
%
% WW 06-2019

%% Determine numbers

% Determine averaged entries in motivelist
if sg_check_param(o,'partavg')
    motl_idx = ismember(o.allmotl.motl_idx,o.rand_motl);
    n_motls = o.n_rand_motls;
else
    motl_idx = ismember(o.allmotl.motl_idx,o.motl_idx); % Not redundant for multientry motivelists
    n_motls = o.n_motls;
end

% Check score threshold
if sg_check_param(p(idx),'score_thresh')
    score_thresh = p(idx).score_thresh;
else
    score_thresh = 0;
end

% Determine requirements for averaging
switch o.motl_type
    
    case {1,2}
        
        % Parse halfset
        switch o.halfset_mode
            case 'single'
                halfset_idx = ismember([o.rand_halfset{motl_idx,1}],o.motl_idx);
                a_idx = repmat(reshape(strcmp(o.rand_halfset(halfset_idx,2),'A'),1,n_motls),o.n_classes,1); 
            case 'split'
                a_idx = repmat(reshape(strcmp(o.allmotl.halfset(motl_idx),'A'),1,n_motls),o.n_classes,1); 
        end
        
        % Parse thresholded scores
        score_idx = repmat(reshape((o.allmotl.score(motl_idx) >= score_thresh),1,n_motls),o.n_classes,1); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == repmat(reshape(o.allmotl.class(motl_idx),1,n_motls),o.n_classes,1); 
        
        
    case 3
        
        % Parse halfset
        switch o.halfset_mode
            case 'single'
                halfset_idx = ismember([o.rand_halfset{motl_idx(1:o.n_classes:numel(motl_idx)),1}],o.motl_idx); % Parse non-redundanct indices
                a_idx = repmat(reshape(strcmp(o.rand_halfset(halfset_idx,2),'A'),1,n_motls),o.n_classes,1); 
            case 'split'
                a_idx = reshape(strcmp(o.allmotl.halfset(motl_idx),'A'),o.n_classes,n_motls); 
        end
                
        % Parse thresholded scores
        score_idx = reshape((o.allmotl.score(motl_idx) >= score_thresh),o.n_classes,n_motls); 
        
        % Parse class 
        class_idx = repmat(o.classes(:),1,n_motls) == reshape(o.allmotl.class(motl_idx),o.n_classes,n_motls);
        
end

% Initialize array
n_subtomos = zeros(o.n_classes,2,'single');

% Sum halfset A
n_subtomos(:,1) = sum((a_idx & score_idx & class_idx),2);
n_subtomos(:,2) = sum((~a_idx & score_idx & class_idx),2);

        
        
        
        
