function o = initialize_o_struct(p,s,idx,task)
%% initialize_o_struct
% Initialize 'o' struct array and store some parellization parameters.
%
% WW 06-2023

%% Initalize 'o'

% Initilaize
o = struct();

% Parse directories
disp([s.cn,'Parsing directories...']);
o = parse_stopgap_directories(p,o,s,idx,task);


% Copy core/node parameters
disp([s.cn,'Parsing node/core parameters...']);
o.procnum = s.procnum;
o.n_cores = s.n_cores;
o.n_nodes = s.n_nodes;

% Cleanup comm folder
clear_comm_folder(p,o,s,idx);


% Assign node ID
if sg_check_param(s,'node_id')
    o.node_id = s.node_id;
else
    
    o.node_id = 1;
end

   
% Check for local core ID
if sg_check_param(s,'local_id')

    % Assign from settings
    o.local_id = s.local_id;

else


    % Check if cores per node is an integer
    if ~mod(o.cores_on_node,1)

        % Calculate local core ID
        o.local_id = o.procnum - (floor((o.procnum-1)/o.cores_on_node)*o.cores_on_node);
        
    else
        
        % Set default parameters
        o.n_nodes = 1;
        o.local_id = o.proncum;        
        warning([s.cn,'ACHTUNG!!! Cores per node is NOT an integer! cannot determine local core number!!!']);

    end

   

end



% Calculate cores per node
if sg_check_param(s,'cpus_on_node')
    
    % Get from settings
    o.cores_on_node = s.cpus_on_node;
    
    % Get counts from each node
    o = get_cores_per_node(p,o,s,idx);
        
else
    
    % Assume even split
    o.cores_on_node = o.n_cores/o.n_nodes;     
    o.cores_per_node = ones(o.n_nodes,1).*o.cores_on_node;
    
end





