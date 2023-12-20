function o = initialize_motl_for_parallel_average(p,o,s,idx)
%% initialize_motl_for_parallel_average
% Read run settings and determine motls for parallel averaging.
%
% WW 05-2021

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

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');


% Check for partial average
o.partavg = false;
if sg_check_param(p(idx),'subset')
    if (p(idx).subset < 100) && strcmp(avg_mode,'partial')
        o.partavg = true;
    end
end


%% Determine motls for averaging
disp([s.cn,'Initializing motivelist for parallel averaging...']);



% Deterine motls per node
if o.partavg
    % Calculate job parameters
    [node_start_idx, node_end_idx, node_job_array] = job_start_end(o.n_rand_motls, o.n_nodes, o.node_id);
    % Parse motl indices
    o.node_avg_motl = o.rand_motl(node_start_idx:node_end_idx);
else
    % Calculate job parameters
    [node_start_idx, node_end_idx, node_job_array] = job_start_end(o.n_motls, o.n_nodes, o.node_id);
    % Parse motl indices
    o.node_avg_motl = o.motl_idx(node_start_idx:node_end_idx);
end


% Number of entries to align per node
o.n_avg_motls = node_job_array(o.node_id,1);    


% Force shape
o.node_avg_motl = reshape(o.node_avg_motl,1,o.n_avg_motls);


%% Split motl within node

% Check for parallel averagig core
switch mode{1}
    case 'ali'
        o.n_cores_p_avg =  determine_n_p_avg_cores(o.n_avg_motls,o.cores_on_node);
        o.p_avg_cores = round(linspace(1,o.cores_on_node,o.n_cores_p_avg));        
        o.p_avg_core = any(o.p_avg_cores==o.local_id);
        o.p_avg_procnum = find(o.p_avg_cores==o.local_id);
    case 'avg'
        o.p_avg_cores = 1:o.cores_on_node;
        o.n_cores_p_avg = o.cores_on_node;
        o.p_avg_core = true;
        o.p_avg_procnum = o.local_id;
end

% Calculate job for each averaging core
if o.p_avg_core

    % Calculate job parameters
    if o.partavg
        [o.p_avg_start, o.p_avg_end, o.p_avg_job_array] = job_start_end(o.n_avg_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    else
        [o.p_avg_start, o.p_avg_end, o.p_avg_job_array] = job_start_end(o.n_avg_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    end
% else
%     
%     % Job parameters for non-averaging node
%     [~,~,o.job_array] = job_start_end(o.n_motls, o.n_cores_p_avg);    % Necessary for copy core that isn't averaging
end 


%% Determine parameters for final averaging

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

% Determine parameters on parallel cores for final averaging
if o.f_avg_core
    
    % Determine procnums of all parallel averaging cores
    switch mode{1}
        
        case 'ali'            
            % Temporary cell to hold parallel averaging procnums
            temp_procnums = cell(o.n_nodes,1);

            % Loop through each node
            for i = 1:o.n_nodes
                n_p_avg_cores_node =  determine_n_p_avg_cores(node_job_array(i,1),o.cores_on_node);   % Number of averaging cores per node
                temp_procnums{i} = round(linspace(1,o.cores_on_node,n_p_avg_cores_node))+((i-1)*o.cores_on_node);   
            end
            
            % List of all parallel averaging procnums
            o.p_avg_procnums = [temp_procnums{:}];

        case 'avg'
            % List of all parallel averaging procnums
            o.p_avg_procnums = 1:o.n_cores;
    end
    
    % Total number of parallel averaging cores
    o.total_p_avg_cores = numel(o.p_avg_procnums);
    
    % Write output for watcher
    csvwrite([p(idx).rootdir,o.commdir,'n_p_avg_',num2str(p(idx).iteration)],o.total_p_avg_cores);
    

end


%% Copy local

% Local copying
if o.copy_local
    
    % Only copy for parallel averaging
    if p(idx).completed_p_avg  
        disp([s.cn,' Parallel average already completed... Skipping local copying step...']);
        return
    end
    
    % Initialize list name
    subtomolist_name = [o.rootdir,'/subtomo_list.txt'];
    
    if o.copy_core
        disp([s.cn,'Copying subtomograms to be aligned to local temporary folder...']);
               
        
        % Generate list        
        disp([s.cn,'Generating list of subtomograms to copy...']);
        fid = fopen(subtomolist_name,'w');
%         for i = node_start_idx:node_end_idx
%             % Parse subtomogram number
%             if o.partavg
%                 motl_idx = find(o.allmotl.motl_idx == o.rand_motl(i),1);    % Find is in case of multi-index motl
%             else
%                 motl_idx = find(o.allmotl.motl_idx == o.motl_idx(i),1);
%             end
%             subtomo_num = o.allmotl.subtomo_num(motl_idx);
%             
%             
%             % Parse filename
%             subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
%             
%             % Write filename to list
%             fprintf(fid,'%s\n',subtomo_name);
%         end
        for i = 1:o.n_avg_motls
            
            % Parse subtomogram number
            motl_idx = find(o.allmotl.motl_idx == o.node_avg_motl(i),1);
            subtomo_num = o.allmotl.subtomo_num(motl_idx);
                        
            % Parse filename
            subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
            
            % Write filename to list
            fprintf(fid,'%s\n',subtomo_name);
        end
        fclose(fid);
        disp([s.cn,'Subtomogram list completed!!! Copying ',num2str(o.n_avg_motls),' subtomograms...']);
    end
    
    % Copy files
    time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,subtomolist_name,true);
    if o.copy_core
        disp([s.cn,'Subtomograms copied in: ',num2str(time)]);
    end
    
end






  

