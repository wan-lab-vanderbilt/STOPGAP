function o = initialize_motl_for_parallel_average(p,o,s,idx)
%% initialize_motl_for_parallel_average
% Read run settings and determine motls for parallel averaging.
%
% WW 06-2023

%% Check check

% Check averaging type
if sg_check_param(p(idx),'avg_mode')
    avg_mode = p(idx).avg_mode;
elseif sg_check_param(p(idx),'subset')
    if p(idx).subset < 100
        avg_mode = 'partial';
    else
        avg_mode = 'full';
    end
else
    avg_mode = 'full';
end



%% Determine motls for averaging
disp([s.cn,'Initializing motivelist for parallel averaging...']);

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

% Determine parallel averagig cores
o = assign_parallel_avg_cores(p,o,s,idx);

% Check for partial average
o.partavg = false;
if sg_check_param(p(idx),'subset')
    if (p(idx).subset < 100) && strcmp(avg_mode,'partial')
        o.partavg = true;
    end
end
                
% Check for final averaging core
switch mode{2}
    
    case 'singleref'
        
        o.f_avg_core = o.procnum == 1;
        o.f_avg_class = 1;
        o.n_f_avg_class = 1;
        o.n_cores_f_avg = 1;
        
        
    otherwise
        % Evenly split classes amongst cores
        f_avg_cores = repmat(1:o.n_cores,[ceil(o.n_classes/o.n_cores),1]);
        f_avg_cores = f_avg_cores(1:o.n_classes);
        
        % Assign final averaging core
        o.f_avg_core = any(f_avg_cores == o.procnum);
        
        % Assign classes to core
        if o.f_avg_core
            o.f_avg_class = o.classes((f_avg_cores == o.procnum));
            o.n_f_avg_class = numel(o.f_avg_class);
        end
        
        % Number of final averaging cores
        if o.n_classes > o.n_cores
            o.n_cores_f_avg = o.n_cores;
        else
            o.n_cores_f_avg = o.n_classes;
        end
end
    

if o.p_avg_core % || o.f_avg_core

    % Calculate job parameters
    if o.partavg
        [o.p_avg_start, o.p_avg_end, o.job_array] = job_start_end(o.n_rand_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    else
        [o.p_avg_start, o.p_avg_end, o.job_array] = job_start_end(o.n_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    end
else
    
    % Job parameters for non-averaging node
    [~,~,o.job_array] = job_start_end(o.n_motls, o.n_cores_p_avg);    % Necessary for copy core that isn't averaging
end 
  
  
%% Copy local




% Local copying
if o.copy_local
    
    % Initialize list name
    subtomolist_name = [o.rootdir,'/subtomo_list.txt'];

            
    if o.copy_core
        disp([s.cn,'Copying subtomograms to be averaged to local temporary folder...']);
        
%         % Determine local core indices in job array
%         [~, local_idx] = intersect(o.p_avg_cores,o.node_cores);
%         n_local_p_avg_cores = numel(local_idx);
%         
%         % Determine motl indices subtomograms to be copied
%         motl_idx_cell = cell(n_local_p_avg_cores,1);
%         for i = 1:n_local_p_avg_cores
%             motl_idx_cell{i} = o.job_array(local_idx(i),2):o.job_array(local_idx(i),3);
%         end
%         avg_motl_idx = [motl_idx_cell{:}];  
%         n_avg_motl = numel(avg_motl_idx);
        
        % Determine starting index for averaging cores on current node
        if o.node_id == 1
            start_idx = 1;
        else    
            start_idx = sum(o.n_p_avg_cores_per_node(1:o.node_id-1)) + 1;            
        end
        
        % Calculate ending index for averaging cores on current node
        end_idx = start_idx + o.n_p_avg_cores_per_node(o.node_id) - 1;
        
        % Determine motl indices subtomograms to be copied
        motl_idx_cell = cell(o.n_p_avg_cores_per_node(o.node_id),1);
        cell_idx = 1;
        for i = start_idx:end_idx
            motl_idx_cell{cell_idx} = o.job_array(i,2):o.job_array(i,3);
            cell_idx = cell_idx + 1;
        end
        avg_motl_idx = [motl_idx_cell{:}];  
        n_avg_motl = numel(avg_motl_idx);
        
        
        % Generate list
        disp([s.cn,'Generating list of subtomograms to copy...']);
        fid = fopen(subtomolist_name,'w');
        for i = 1:n_avg_motl
            % Parse subtomogram number
            if o.partavg
                motl_idx = find(o.allmotl.motl_idx == o.rand_motl(avg_motl_idx(i)),1);
            else
                motl_idx = find(o.allmotl.motl_idx == o.motl_idx(avg_motl_idx(i)),1);
            end
            subtomo_num = o.allmotl.subtomo_num(motl_idx);
            
            
            % Parse filename
            subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext]; 
            
            % Write filename to list
            fprintf(fid,'%s\n',subtomo_name);
        end
        fclose(fid);                
        disp([s.cn,'Subtomogram list completed!!! Copying ',num2str(n_avg_motl),' subtomograms...']);
    end
    
    % Copy files
    time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,subtomolist_name,true,s.copy_function);
    if o.copy_core
        disp([s.cn,'Subtomograms copied in: ',num2str(time),' seconds!!!']);
    end
end






  
  
