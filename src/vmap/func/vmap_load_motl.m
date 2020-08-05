function o = vmap_load_motl(p,o,s,idx)
%% vmap_load_motl
% Load motivelist and parse the necessary variables for variance map
% calculation.
%
% WW 05-2019


%% Load motivelist

% Read motivelist
o.motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];
o.allmotl = sg_motl_read2([p(idx).rootdir,o.motl_name]);
o.n_motls = numel(o.allmotl.motl_idx);
o.motl_type = sg_motl_check_type(o.allmotl);

%% Parse information

% Parse class information
switch p(idx).vmap_mode
    case 'singleref'
        o.classes = 1;
        o.n_classes = 1;    
    case 'multiclass'
        o.classes = unique(o.allmotl.class);
        o.n_classes = numel(o.classes);
end


% Find all unique subtomogram entries        
o.motl_idx = unique(o.allmotl.motl_idx);
o.n_motls = numel(o.motl_idx);  




%% Determine parallelization parameters


% Parallel job parameters
[o.p_avg_start, o.p_avg_end, o.job_array] = job_start_end(o.n_motls, o.n_cores, o.procnum);
o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;



% Check for final averaging node
switch p(idx).vmap_mode
    
    case 'singleref'
        
        o.f_avg_node = o.procnum == 1;
        o.f_avg_class = 1;
        o.n_f_avg_class = 1;
        
        
    otherwise
        % Evenly split classes amongst cores
        f_avg_cores = repmat(1:o.n_cores,[ceil(o.n_classes/o.n_cores),1]);
        f_avg_cores = f_avg_cores(1:o.n_classes);
        
        % Assign final averaging node
        o.f_avg_node = any(f_avg_cores == o.procnum);
        
        % Assign classes to node
        if o.f_avg_node
            o.f_avg_class = o.classes((f_avg_cores == o.procnum));
            o.n_f_avg_class = numel(o.f_avg_class);
        end
end




