function o = initialize_motl_for_parallel_tps(p,o,s,idx)
%% initialize_motl_for_parallel_tps
% Read run settings and determine motls for parallel tube power spectrum
% calculation.
%
% WW 10-2022


%% Determine motls for averaging
disp([s.cn,'Initializing motivelist for parallel tube power spectra calculations...']);


% Deterine motls per node
[node_start_idx, node_end_idx, node_job_array] = job_start_end(o.n_motls, o.n_nodes, o.node_id); % Calculate job parameters
o.node_tps_motl = o.motl_idx(node_start_idx:node_end_idx); % Parse motl indices

% Number of entries to align per node
o.n_tps_motls = node_job_array(o.node_id,1);    

% Force shape
o.node_tps_motl = reshape(o.node_tps_motl,1,o.n_tps_motls);



%% Split motl within node

% Check for parallel averagig core
o.p_tps_cores = 1:o.cores_on_node;
o.n_cores_p_tps = o.cores_on_node;
o.p_tps_core = true;
o.p_tps_procnum = o.local_id;


% Calculate job for each averaging core
[o.p_tps_start, o.p_tps_end, o.p_tps_job_array] = job_start_end(o.n_tps_motls, o.n_cores_p_tps, o.p_tps_procnum);
o.n_p_tps = o.p_tps_end - o.p_tps_start + 1;



%% Determine parameters for final averaging

% Check for final averaging core
switch p(idx).tps_mode
    
    case 'singleref'
        
        o.f_tps_core = o.procnum == 1;
        o.f_tps_class = 1;
        o.n_f_tps_class = 1;
        o.n_cores_f_tps = 1;
        
        
    otherwise
        
        % Evenly split classes amongst cores
        f_tps_cores = repmat(1:o.n_cores,[ceil(o.n_classes/o.n_cores),1]);
        f_tps_cores = f_tps_cores(1:o.n_classes);
        
        % Assign final averaging core
        o.f_tps_core = any(f_tps_cores == o.procnum);
        
        % Assign classes to core
        if o.f_tps_core
            o.f_tps_class = o.classes((f_tps_cores == o.procnum));
            o.n_f_tps_class = numel(o.f_tps_class);
        end
        
        % Number of final averaging cores
        if o.n_classes > o.n_cores
            o.n_cores_f_tps = o.n_cores;
        else
            o.n_cores_f_tps = o.n_classes;
        end
end

% Determine parameters on parallel cores for final averaging
if o.f_tps_core
    
    % List of all parallel averaging procnums
    o.p_tps_procnums = 1:o.n_cores;
    
    
    % Total number of parallel averaging cores
    o.total_p_tps_cores = numel(o.p_tps_procnums);
    
    % Write output for watcher
    csvwrite([p(idx).rootdir,o.commdir,'n_p_tps_',num2str(idx)],o.total_p_tps_cores);
    

end


%% Copy local

% Local copying
if o.copy_local
    
    % Only copy for parallel averaging
    if p(idx).completed_p_tps
        disp([s.cn,' Parallel calculations already completed... Skipping local copying step...']);
        return
    end
    
    % Initialize list name
    subtomolist_name = [o.rootdir,'/subtomo_list.txt'];
    
    if o.copy_core
        disp([s.cn,'Copying subtomograms to be processed to local temporary folder...']);
               
        
        % Generate list        
        disp([s.cn,'Generating list of subtomograms to copy...']);
        fid = fopen(subtomolist_name,'w');

        for i = 1:o.n_tps_motls
            
            % Parse subtomogram number
            motl_idx = find(o.allmotl.motl_idx == o.node_tps_motl(i),1);
            subtomo_num = o.allmotl.subtomo_num(motl_idx);
                        
            % Parse filename
            subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
            
            % Write filename to list
            fprintf(fid,'%s\n',subtomo_name);
        end
        fclose(fid);
        disp([s.cn,'Subtomogram list completed!!! Copying ',num2str(o.n_tps_motls),' subtomograms...']);
    end
    
    % Copy files
    time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,subtomolist_name,true,s.copy_function);
    if o.copy_core
        disp([s.cn,'Subtomograms copied in: ',num2str(time)]);
    end
    
end






  

