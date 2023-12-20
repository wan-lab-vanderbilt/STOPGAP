function o = check_copy_local(o,s)
%% check_copy_local
% Check if sufficient input settings are given for local copying.
%
% WW 04-2021

%% Check check!!!

% Check if local copying is enabled
if sg_check_param(s,'copy_local')
    
    % Check if sufficent settings are given for local copying
    if sg_check_param(s,'n_nodes') && sg_check_param(s,'user_id') && sg_check_param(s,'job_id')
        
        % Set local copying 
        o.copy_local = s.copy_local;    
        
        % Check if cores per node is an integer
        if mod(o.cores_on_node,1)

            % If non-integer, issue warning
            o.copy_local = false;
            warning([s.cn,'ACHTUNG!!! Cores per node is NOT an integer! cannot determine local core number!!!']);

        end
        
%         % Copy core and node numbers
%         o.n_cores = s.n_cores;
%         o.n_nodes = s.n_nodes;
%         
%         % Calculate cores per node
%         o.cores_on_node = o.n_cores/o.n_nodes;
            
%         % Check for local core ID
%         if sg_check_param(s,'local_id')
%             
%             % Assign from settings
%             o.local_id = s.local_id;
%             
%         else
%                         
%             
%             % Check if cores per node is an integer
%             if mod(o.cores_on_node,1)
%                 
%                 % If non-integer, issue warning
%                 o.copy_local = false;
%                 warning([s.cn,'ACHTUNG!!! Cores per node is NOT an integer! cannot determine local core number!!!']);
%                 
%             else
%                 
%                 % Calculate local core ID
%                 o.local_id = o.procnum - (floor((o.procnum-1)/o.cores_on_node)*o.cores_on_node);
%                 
%             end
%             
% %             % Assign node ID
% %             if sg_check_param(s,'node_id')
% %                 o.node_id = s.node_id;
% %             else
% %                 o.node_id = ceil(o.procnum/o.cores_on_node);
% %             end
%             
%             
%             
%             
%         end

        
        
        
    else
        
        % Issue warning
        o.copy_local = false;
        warning([s.cn,'ACHTUNG!!! Insufficient parameters for local copying!!! Number of nodes is unassigned!!!']);
        
    end
    
else
    
    % Not enabled
    o.n_cores = s.n_cores;
    o.n_nodes = s.n_nodes;
    o.copy_local = false;
    
end