function ali = initialize_align_struct(p,o,idx,motl)
%% initialize_align_struct
% Initialize an 'ali' struct to hold all angular search results.
%
% WW 10-2018


%% Initialize struct

% Check for stochastic search
if any(strcmp(p(idx).search_mode,{'shc','sga'}))
    stochastic = true;
else
    stochastic = false;
end

% Check for simulated annealing
if sg_check_param(p(idx),'temperature')
    if p(idx).temperature > 0
        stochastic = true;
    end
end


% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

% Generate struct depending on mode
switch mode{2}
    
    case {'singleref','multiclass'}
        
        % Initialize struct
        ali = repmat(struct('score',-2,'halfset',motl.halfset,...
                            'old_shift',[motl.x_shift,motl.y_shift,motl.z_shift],...
                            'new_shift',[0,0,0],...
                            'phi',0,'psi',0,'the',0,...
                            'class',motl.class),o.n_ang,1);

        % Compose new euler angles
        [phi,psi,the] = compose_search_eulers(p,o,idx,motl,1);
        [ali.phi] = phi{:};
        [ali.psi] = psi{:};
        [ali.the] = the{:};    
        
    case 'multiref'
        
        switch o.motl_type
            
            % Multi-entry motivelist
            case 3
                
                % Number of entries        
                n_entry = o.n_classes;
                
                % Initalize cell for ali arrays
                ali_cell = cell(n_entry,1);
                
                % Initialize array for each entry
                for i = 1:n_entry

                    % Initialize struct
                    ali_cell{i} = repmat(struct('score',-2,'halfset',motl.halfset{i},...
                        'old_shift',[motl.x_shift(i),motl.y_shift(i),motl.z_shift(i)],...
                        'new_shift',[0,0,0],...
                        'phi',0,'psi',0,'the',0,...
                        'class',motl.class(i)),o.n_ang,1);

                    % Compose new euler angles
                    [phi,psi,the] = compose_search_eulers(p,o,idx,motl,i);
                    [ali_cell{i}.phi] = phi{:};
                    [ali_cell{i}.psi] = psi{:};
                    [ali_cell{i}.the] = the{:};    

                    % Randomize for stochastic searches
                    if stochastic
                        r_idx = randperm(o.n_ang-1)+1;
                        ali_cell{i}(2:end) = ali_cell{i}(r_idx);
                    end
                end
                
                % Concatenate ali
                ali = cat(2,ali_cell{:});
                
                
            % Single-entry motivelist
            otherwise
                
                % Initialize struct
                ali = repmat(struct('score',-2,'halfset',motl.halfset,...
                                    'old_shift',[motl.x_shift,motl.y_shift,motl.z_shift],...
                                    'new_shift',[0,0,0],...
                                    'phi',0,'psi',0,'the',0,...
                                    'class',motl.class),o.n_ang,1);

                % Compose new euler angles
                [phi,psi,the] = compose_search_eulers(p,o,idx,motl,1);
                [ali.phi] = phi{:};
                [ali.psi] = psi{:};
                [ali.the] = the{:}; 
                
                % Repeat for all classes
                ali = repmat(ali,o.n_classes,1);
                
                % Set classes 
                if stochastic
                    % Place top class first
                    top_idx = find(o.classes == motl.class);
                    other_idx = setdiff(1:o.n_classes,top_idx);
                    class_order = o.classes([top_idx,other_idx(randperm(o.n_classes-1))]);
                else
                    class_order = o.classes;
                end
                classes = reshape(repmat(reshape(num2cell(class_order),1,o.n_classes),o.n_ang,1),[],1);
                [ali.class] = classes{:};
                
                % Randomize array
                if stochastic
                    ali(2:end) = ali(randperm((o.n_ang*o.n_classes)-1)+1);
                end
                
        end
end







    
