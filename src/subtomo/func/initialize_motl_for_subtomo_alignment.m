function o = initialize_motl_for_subtomo_alignment(p,o,s,idx)
%% initialize_motl_for_subtomo_alignment
% Read run settings and determine motls for subtomogram alignment.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Notes on local copying:
% If local copying is set on mode 1, i.e. an even division of subtomograms
% between nodes, packets are set per node. Otherwise, packets are set for
% the full dataset.
%
% WW 10-2021


%% Determine motls for alignment
disp([s.cn,'Determining parameters for parallel alignment... ']);

% Check for subset processing
subset = false;
if sg_check_param(p(idx),'subset')
    if p(idx).subset < 100
        subset = true;
    end
end

% Determine first and last core numbers on node
node_start_core = o.procnum - o.local_id + 1;
node_end_core = node_start_core + o.cores_on_node - 1;


% Deterine motls per node
if o.copy_local == 1
    
    % Calculate packet size
    o.total_packets = s.packets_per_core*o.cores_on_node;
    
    if subset
        % Check packet size
        if o.n_rand_motls < o.total_packets
            o.total_packets = o.cores_on_node;
        end
%         % Calculate job parameters
%         [node_start_idx, node_end_idx, ~] = job_start_end(o.n_rand_motls, o.n_nodes, o.node_id);
                
        % Calculate job array
        [~,~,job_array] = job_start_end(o.n_rand_motls, o.n_cores);
        node_start_idx = job_array(node_start_core,2);
        node_end_idx = job_array(node_end_core,3);
        
        % Parse motl indices
        o.ali_motl = o.rand_motl(node_start_idx:node_end_idx);
    else
        % Check packet size
        if o.n_motls < o.total_packets
            o.total_packets = o.cores_on_node;
        end
%         % Calculate job parameters
%         [node_start_idx, node_end_idx, ~] = job_start_end(o.n_motls, o.n_nodes, o.node_id);        
        
        % Calculate job array
        [~,~,job_array] = job_start_end(o.n_motls, o.n_cores);
        node_start_idx = job_array(node_start_core,2);
        node_end_idx = job_array(node_end_core,3);
        
        % Parse motl indices
        o.ali_motl = o.motl_idx(node_start_idx:node_end_idx);
        
    end        

    % Number of entries to align per node
    o.n_ali_motls = node_end_idx - node_start_idx + 1;   
    
%     % Calculate packet array
%     [~,~,o.packet_array] = job_start_end(o.n_ali_motls,o.total_packets);
    
else
    
    % Calculate packet size
    o.total_packets = s.packets_per_core*o.n_cores;
    if o.n_motls < o.total_packets
        o.total_packets = o.n_cores;
    end
    
    % Calculate parameters
    if subset        
        % Check packet size
        if o.n_rand_motls < o.total_packets
            o.total_packets = o.cores_on_node;
        end
        % Number of entries to align
        o.n_ali_motls = o.n_rand_motls;            
        % Parse motl indices
        o.ali_motl = o.rand_motl;
    else
        % Check packet size
        if o.n_motls < o.total_packets
            o.total_packets = o.cores_on_node;
        end
        % Number of entries to align
        o.n_ali_motls = o.n_motls;    
        % Parse motl indices
        o.ali_motl = o.motl_idx;
        
    end
    
%     % Calculate packet array
%     [~,~,o.packet_array] = job_start_end(o.n_ali_motls,o.total_packets);
    
end

% Calculate packet array
[~,~,o.packet_array] = job_start_end(o.n_ali_motls,o.total_packets);


% Force shape
o.ali_motl = reshape(o.ali_motl,1,o.n_ali_motls);


if o.copy_local == 1
    disp([s.cn,num2str(o.n_ali_motls),' subtomograms to be aligned on node ',num2str(o.node_id),' in ',num2str(o.total_packets),' packets...']);
else
    disp([s.cn,num2str(o.n_ali_motls),' subtomograms to be aligned in ',num2str(o.total_packets),' packets...']);    
end






%% Copy local

% Local copying
if o.copy_local == 1
    
    % Initialize list name
    subtomolist_name = [o.rootdir,'/subtomo_list.txt'];
    
    if o.copy_core
        disp([s.cn,'Copying subtomograms to be aligned to local temporary folder...']);               
        
        % Generate list        
        disp([s.cn,'Generating list of subtomograms to copy...']);
        fid = fopen(subtomolist_name,'w');
        for i = node_start_idx:node_end_idx
            % Parse subtomogram number
            if subset
                motl_idx = find(o.allmotl.motl_idx == o.rand_motl(i),1);    % Find is in case of multi-index motl
            else
                motl_idx = find(o.allmotl.motl_idx == o.motl_idx(i),1);
            end
            subtomo_num = o.allmotl.subtomo_num(motl_idx);
            
            
            % Parse filename
            subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
            
            % Write filename to list
            fprintf(fid,'%s\n',subtomo_name);
        end
        fclose(fid);
        disp([s.cn,'Subtomogram list completed!!! Copying ',num2str(o.n_ali_motls),' subtomograms...']);
    end
    
    % Copy files
    time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,subtomolist_name,true);
    if o.copy_core
        disp([s.cn,'Subtomograms copied in: ',num2str(time)]);
    end
  
    
elseif o.copy_local == 2
    
    if o.copy_core       
        
        % Generate subset list 
        if subset
            disp([s.cn,'Generating subset list of subtomograms to copy...']);
            subtomolist_name = [o.rootdir,'/subtomo_list.txt'];
            fid = fopen(subtomolist_name,'w');
            for i = 1:o.n_ali_motls
                % Parse subtomogram number
                motl_idx = find(o.allmotl.motl_idx == o.rand_motl(i),1);    % Find is in case of multi-index motl
                subtomo_num = o.allmotl.subtomo_num(motl_idx);
                        
                % Parse filename
                subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
            
                % Write filename to list
                fprintf(fid,'%s\n',subtomo_name);
            end
            fclose(fid);
            disp([s.cn,'Subtomogram list completed!!! Copying ',num2str(o.n_ali_motls),' subtomograms...']); 
        else
            disp([s.cn,'Copying ',num2str(o.n_ali_motls),' subtomograms...']);   
        end

    end
        
    
    
    % Copy files
    if subset
        
        time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,subtomolist_name,true);
        if o.copy_core
            disp([s.cn,'Subtomograms copied in: ',num2str(time)]);
        end
        
    else
        
        time = copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','subtomos_copied',s.wait_time,o.subtomodir,false);
        if o.copy_core
            disp([s.cn,'Subtomograms copied in: ',num2str(time)]);
        end
        
    end
    
end










