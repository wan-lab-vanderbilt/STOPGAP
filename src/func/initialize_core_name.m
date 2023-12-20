function s = initialize_core_name(s)
%% initialize_core_name
% A function to initialize the core name depending on the given input
% settings.
%
% WW 03-2021

%% Initialize node name

% Generate core string
core_str = num2str(s.procnum,['core%0',num2str(ceil(log10(s.n_cores+1))),'i']);

% Generate node name string
if sg_check_param(s,'node_name')
    node_name = ['_',s.node_name];
else
    node_name = '';
end

% Fill number of nodes
if sg_check_param(s,'n_nodes')
    s.n_nodes = s.n_nodes;
else
    s.n_nodes = 1;
end

% Generate node ID string
if sg_check_param(s,'node_id')
    node_id = num2str(s.node_id,['_node%0',num2str(ceil(log10(s.n_nodes+1))),'i']);
else
    node_id = '';
end

% Generate local ID string
if sg_check_param(s,'local_id')
    cores_per_node = s.n_cores/s.n_nodes;
    local_id = num2str(s.local_id,['-%0',num2str(ceil(log10(cores_per_node+1))),'i']);
else
    local_id = '';
end

% Concatenate string
s.cn = [core_str,node_name,node_id,local_id,': '];


