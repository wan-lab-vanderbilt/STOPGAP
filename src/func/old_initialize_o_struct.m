function o = initialize_o_struct(s)
%% initialize_o_struct
% Initialize 'o' struct array and store some parellization parameters.
%
% WW 05-2023

%% Initalize 'o'

% Initilaize
o = struct();

% Copy core/node parameters
o.procnum = s.procnum;
o.n_cores = s.n_cores;
o.n_nodes = s.n_nodes;



% Calculate cores per node
if sg_check_param(s,'cpus_on_node')
    o.cores_on_node = s.cpus_on_node;
else
    o.cores_on_node = o.n_cores/o.n_nodes;     % Assume even split
end

% Assign node ID
if sg_check_param(s,'node_id')
    o.node_id = s.node_id;
else
    o.node_id = ceil(o.procnum/o.cores_on_node);
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
        o.node_id = 1;
        o.local_id = o.proncum;        
        warning([s.cn,'ACHTUNG!!! Cores per node is NOT an integer! cannot determine local core number!!!']);

    end

   

end

