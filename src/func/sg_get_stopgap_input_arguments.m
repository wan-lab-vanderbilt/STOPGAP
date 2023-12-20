function [parser_param,param] = sg_get_stopgap_input_arguments()
%% sg_get_stopgap_input_arguments
% A function to return an array containing input arguments.
%
% WW 05-2018


%% Parameters
% Intialize parameter struct
param = struct();


% Directory and files
param.dir = {'rootdir', 'paramfilename';
             'str',     'str';
             'req',     'req'};
         
% Parallelization parameters
param.parallel = {'n_cores', 'procnum';
                  'num',     'num';
                  'req',     'req'};
             
% Cluster/Node parameters
param.cluster = {'user_id', 'job_id', 'node_name', 'node_id', 'n_nodes', 'cpus_on_node', 'local_id', 'copy_local';
                 'str',     'str',    'str',       'num',     'num',     'num',          'num',      'num';
                 'nrq',     'nrq',    'nrq',       'nrq',     'nrq',     'nrq',          'nrq',      'nrq'};
             
             
     
%% Concatenate parameters      

% Parse fields from struct
fields = fieldnames(param);
n_fields = numel(fields);
param_cell = cell(1,n_fields);
for i = 1:n_fields
    param_cell{i} = param.(fields{i});
end

% Concatenate fields
parser_param = [param_cell{:}];




