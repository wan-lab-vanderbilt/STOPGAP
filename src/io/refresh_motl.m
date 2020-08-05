function o = refresh_motl(p,o,s,idx)
%% refresh_motl
% A function to read a motivelist if it has been changed since last
% iteration.
%
% WW 06-2019


%% Check for refresh
disp([s.nn,'Refreshing motivelist...']);

% Check iteration
iteration = p(idx).iteration;

% Parse mode
if isfield(p(idx),'subtomo_mode')
    mode = strsplit(p(idx).subtomo_mode,'_');
    
    % Increment iteration after alignment
    if strcmp(mode{1},'ali') && p(idx).completed_ali         
        iteration = p(idx).iteration + 1;
    end

end


          
% Refresh check
refresh = false;

if ~isfield(o,'allmotl')
    
    % Initial loading
    refresh = true;
    o.motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(iteration),'.star'];

    

elseif ~strcmp(o.motl_name,[o.listdir,'/',p(idx).motl_name,'_',num2str(iteration),'.star'])
    
    % Change in name
    refresh = true;
    o.motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(iteration),'.star'];
    
    
    % Clear old fields
    old_fields = {'allmotl','n_motls','classes','n_classes','subtomos',...
                  'n_subtomos','subset_idx','halfset_mode','halfset',...
                  'rand_halfset','rand_subset_idx','rand_motl'};
    for i = 1:numel(old_fields)
        if isfield(o,old_fields{i})
            o = rmfield(o,old_fields{i});
        end
    end
    
end


%%  Read motive list

if refresh
    
    % Read motive list
    o.allmotl = sg_motl_read2([p(idx).rootdir,o.motl_name]);    
    
    
    % Resort
    sorting_array = cat(2,o.allmotl.tomo_num,o.allmotl.subtomo_num,o.allmotl.class);
    [~,sort_idx] = sortrows(sorting_array,[1,2,3]);
    fields = fieldnames(o.allmotl);
    for i = 1:numel(fields)
        o.allmotl.(fields{i}) = o.allmotl.(fields{i})(sort_idx);
    end
    
    
    % Find unqiue entries
    o.motl_idx = unique(o.allmotl.motl_idx);
    o.n_motls = numel(o.motl_idx);
    
    % Find all unique subtomogram entries        
    o.subtomos = unique(o.allmotl.subtomo_num);
    o.n_subtomos = numel(o.subtomos);
    
    % Parse tomogram information
    o.tomos = unique(o.allmotl.tomo_num);
    o.n_tomos = numel(o.tomos);
      
    % Parse class information
    switch mode{2}
        case 'singleref'
            o.classes = int32(1);
            o.n_classes = 1;
        otherwise            
            o.classes = unique(o.allmotl.class);
            o.n_classes = numel(o.classes);
    end
    
    % Check motl type
    o.motl_type = sg_motl_check_type(o.allmotl,2);                

    
    % Check halfset type
    if all(strcmp(o.allmotl.halfset{1},o.allmotl.halfset))
        o.halfset_mode = 'single';    
        o = randomize_halfsets(o);
    else    
        o.halfset_mode = 'split';        
    end
          
end


% Check for subset processing
if sg_check_param(p(idx),'subset')
    if p(idx).subset ~= 100        
        o = motl_random_subset(p,o,s,idx);     
    end    
end
















