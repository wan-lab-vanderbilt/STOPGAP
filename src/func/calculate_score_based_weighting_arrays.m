function f = calculate_score_based_weighting_arrays(p,o,idx,f)
%% calculate_score_based_weighting_arrays
% Pre-calculating information required for score-based weighting. 
%
% Dimension 1 are the tomograms, dimension 2 are the classes, and dimension
% 3 are min and max scores. 

%% Parse motivelist

% Check for subset processing
if sg_check_param(p(idx),'subset')
    if p(idx).subset ~= 100        
        motl_idx = ismember(o.allmotl.motl_idx,o.rand_motl);    
        motl = parse_motl(o.allmotl,motl_idx);
    else
        motl = o.allmotl;
    end    
end

%% Parse infomation from motivelist

% Initialize array
f.score_array = zeros(o.n_tomos,o.n_classes,2);

% Loop through tomograms
for i = 1:o.n_tomos
    
    % Tomogram index
    tomo_idx = motl.tomo_num == o.tomos(i);
    
    
        
    switch o.motl_type

        case {1,2}
            
            % Loop through classes
            for j = 1:o.n_classes
                % Class index
                class_idx = motl.class == o.classes(j);

                % Parse scores
                temp_scores = motl.score(tomo_idx & class_idx);

                % Fill score array
                if isempty(temp_scores)
                    f.score_array(i,j,1) = 0;
                    f.score_array(i,j,2) = 0;
                else
                    f.score_array(i,j,1) = min(temp_scores);
                    f.score_array(i,j,2) = max(temp_scores);
                end

            end
            
        case 3
            
            % Parse scores
            scores = reshape(motl.score,o.n_classes,o.n_subtomos);
            [~,max_idx] = max(scores,[],1);
            
            for j = 1:o.n_classes
                
                % Parse class scores
                temp_scores = scores(j,max_idx==j);
                
                % Fill score array
                if isempty(temp_scores)
                    f.score_array(i,j,1) = 0;
                    f.score_array(i,j,2) = 0;
                else
                    f.score_array(i,j,1) = min(temp_scores);
                    f.score_array(i,j,2) = max(temp_scores);
                end
                
            end
            
    end
end
