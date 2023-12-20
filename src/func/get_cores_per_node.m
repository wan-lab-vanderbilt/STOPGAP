function o = get_cores_per_node(p,o,s,idx)
%% get_cores_per_node
% A function to communicate the number of cores on each node to all cores. 
%
% WW 06-2023

%% Report number of cores

% For local core 1
if o.local_id == 1
    disp([s.cn,'Node ',num2str(o.node_id),' contains ',num2str(o.cores_on_node),' cores...']);
        
    % Write file containing number of cores
    node_filename = [p(idx).rootdir,o.commdir,'node_',num2str(idx),'_',num2str(o.node_id)];
    temp_filename = [node_filename,'.tmp'];
    dlmwrite(temp_filename,o.cores_on_node);
    system(['mv ',temp_filename,' ',node_filename]);    % For atomic operation
    
end

%% Get number of cores
    
% Root of node number filename
node_filename_root = ['node_',num2str(idx)];

% Wait for all files
wait_for_them([p(idx).rootdir,'/',o.commdir],node_filename_root,o.n_nodes,s.wait_time);

% Read files
o.cores_per_node = zeros(o.n_nodes,1);
for i = 1:o.n_nodes
    t = 1;
    while t <= 5
        try
            o.cores_per_node(i) = dlmread([p(idx).rootdir,'/',o.commdir,node_filename_root,'_',num2str(i)]);
            t = 1000;
        catch
            pause(s.wait_time);
            t = t+1;
        end
    end
end




