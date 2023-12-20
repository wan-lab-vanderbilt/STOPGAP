function o = tm_check_copy_local(p,o,s,idx)
%% tm_check_copy_local
% Check if input files will be copied locally. The first core on each node 
% will be identified and used for all subsequent copying steps.
%
% WW 05-2023

%% Check for local copying

% Check settings
o = check_copy_local(o,s);


% Return if not copying locally
if ~o.copy_local
    
    % Set rootdir to main rootdir
    o.rootdir = p(idx).rootdir;
    
    % Return if not copying locally
    return
end



%% Initialize local directories


% Set local temporary root directory
o.rootdir = [s.localtempdir,'/stopgap_u',s.user_id,'_j',s.job_id,'/'];

% Set first core in node as copy core
if o.local_id == 1
    
    % Set as copy core
    o.copy_core = true;
    disp([s.cn,'Set as copying core!!!']);
    
    
%     % Determine node number
%     if sg_check_param(s,'node_id')
%         o.node_id = s.node_id;
%     else
%         o.node_id = floor((o.procnum-1)/o.cores_on_node)+1;
%     end
    
    % Determine core numers on node
%     o.node_start_core = ((o.node_id - 1)*o.cores_on_node) + 1;
%     o.node_end_core = o.node_start_core + o.cores_on_node - 1;
    o.node_start_core = o.procnum;
    o.node_end_core = o.node_start_core + o.cores_on_node - 1;
    o.node_cores = o.node_start_core:o.node_end_core;

    % Clear copy-communications directory
    system(['mkdir -p ',o.rootdir,'copy_comm/']);
    system(['rm -rf ',o.rootdir,'copy_comm/*']);
    
    
    % Parse remaining directory fields
    d_fields = {'tempdir', 'tmpldir', 'maskdir', 'listdir'};    
    n_dir = numel(d_fields);
    
    % Make remaining directories
    for i = 1:n_dir
        system(['mkdir -p ',o.rootdir,o.(d_fields{i})]);
    end
        
    % Initialization complete
    system(['touch ',o.rootdir,'/copy_comm/init_complete']);
    
else
    
    % Set to non-copy core
    o.copy_core = false;
    
    % Wait for copy core to set up local directory
    wait_for_it([o.rootdir,'/copy_comm/'],'init_complete',s.wait_time);
    
end


disp([s.cn,'Local copying is enabled... Local temporary directory is: ',o.rootdir]);



