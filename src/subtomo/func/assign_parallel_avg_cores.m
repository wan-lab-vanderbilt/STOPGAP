function o = assign_parallel_avg_cores(p,o,s,idx)
%% assign_parallel_avg_cores
% Take in job parameters and assign parallel averaging cores. 
%
% WW 06-2023


%% Check for type of averaging job

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

switch mode{1}
    case 'ali'
        % Determine total number of cores
        o.n_cores_p_avg =  determine_n_p_avg_cores(o.n_motls,o.n_cores);
    case 'avg'        
        % Assign all cores
        o.p_avg_cores = 1:o.n_cores;
        o.n_cores_p_avg = o.n_cores;
        o.p_avg_core = true;
        o.p_avg_procnum = o.procnum;
        o.n_p_avg_cores_per_node = o.cores_per_node;
        
        % Return o struct
        disp([s.cn,'Assigned as parallel averaging core with id ',num2str(o.p_avg_procnum),' out of ',num2str(o.n_cores_p_avg),'...']);
        return
end


%% Determine averagine cores per node

% Roughly assign based on cores per node
o.n_p_avg_cores_per_node = floor((o.cores_per_node./sum(o.cores_per_node)).*o.n_cores_p_avg);

% Descending index of cores per node
[~,core_idx] = sort(o.cores_per_node,'descend');

% Assign remaining cores weighted by cores per node
c = 1;  % Counter
while sum(o.n_p_avg_cores_per_node) < o.n_cores_p_avg
    
    % Add core to node
    o.n_p_avg_cores_per_node(core_idx(c)) = o.n_p_avg_cores_per_node(core_idx(c))+1;
    
    % Cycle counter
    c = c+1;
    if c > numel(o.cores_per_node)
        c = 1;
    end
end


%% Assign cores on nodes

% Determine local parallel averaging cores
o.p_avg_cores = round(linspace(1,o.cores_on_node,o.n_p_avg_cores_per_node(o.node_id)));        

% Check if this core is an averaging core
o.p_avg_core = any(o.p_avg_cores==o.local_id);

% Determine parallel averaging id
if o.p_avg_core
    if o.node_id == 1
        o.p_avg_procnum = find(o.p_avg_cores==o.local_id);
    else    
        o.p_avg_procnum = find(o.p_avg_cores==o.local_id) + sum(o.n_p_avg_cores_per_node(1:o.node_id-1));
    end

    disp([s.cn,'Assigned as parallel averaging core with id ',num2str(o.p_avg_procnum),' out of ',num2str(o.n_cores_p_avg),'...']);

else
    disp([s.cn,'Not assigned as parallel averaging core...']);
end    







