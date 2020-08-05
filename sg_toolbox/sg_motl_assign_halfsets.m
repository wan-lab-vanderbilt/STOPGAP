function sg_motl_assign_halfsets(input_name,output_name,method,renumber)
%% sg_motl_assign_halfsets
% A function for assigning halfsets to a motivelist. Halfsets can either be
% assigned as odd/even ('oddeven') or randomly per tomogram ('random'). The
% renumber option renumbers the halfset prior to randomization; for
% odd/even this ensures even halfsets after cleaning (1 = yes, 0 = no). 
%
% WW 08-2018

%% Check check

if nargin == 2
    method = 'random';
elseif nargin == 3
    renumber = 0;
elseif nargin ~= 4
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end


   
%% Assign halfsets

% Read allmotl
allmotl = sg_motl_read(input_name);

% Check for renumbering
if renumber
    n_motl = numel(allmotl);
    allmotl = sg_motl_fill_field(allmotl,'subtomo_num',1:n_motl);
end


switch method
    
    case 'oddeven'
        
        % Find even indices
        even_idx = mod([allmotl.subtomo_num],2) == 0;
        
        % Assign halfsets
        n_motls = numel(allmotl);
        halfsets  = repmat({'A'},[n_motls,1]);
        halfsets(even_idx) = {'B'};
        
        
        
    case 'random'
        
        % Parse tomograms
        tomos = unique([allmotl.tomo_num]);
        n_tomos = numel(tomos);
        
        % Halfset cell
        halfset_cell = cell(n_tomos,1);
        
        % Odd/even counter
        c = 1;
        
        for i = 1:n_tomos
            
            % Parse tomogram indices
            tomo_idx = [allmotl.tomo_num] == tomos(i);
            n_motls = sum(tomo_idx);
            
            % Tomogram halfset
            temp_halfsets  = repmat({'A'},[n_motls,1]);
            
            % Radomly assign B
            rand_idx = randperm(n_motls);
            if mod(n_motls,2) == 0
                temp_halfsets(rand_idx(1:n_motls/2)) = {'B'};
            else
                % Attempt to evenly split across allmotl
                if c == 1
                    temp_halfsets(rand_idx(1:ceil(n_motls/2))) = {'B'};
                    c = 0;
                else
                    temp_halfsets(rand_idx(1:floor(n_motls/2))) = {'B'};
                    c = 1;
                end
            end
            
            % Store halfsets
            halfset_cell{i} = temp_halfsets;
            
        end
            
        % Concatenate halfsets
        halfsets = cat(1,halfset_cell{:});
        
end

% Assign halfsets
allmotl = sg_motl_fill_field(allmotl,'halfset',halfsets);         
            
% Write output
sg_motl_write(output_name,allmotl);
        
        




