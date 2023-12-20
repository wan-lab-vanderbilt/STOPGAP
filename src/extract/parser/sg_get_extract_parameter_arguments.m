function [parser_param,param] = sg_get_extract_parameter_arguments()
%% get_tm_parameter_arguments
% Reutrn arguments for STOPGAP extraction parameters.
%
% WW 04-2021


%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tomodir', 'commdir', 'listdir', 'tempdir', 'metadir', 'subtomodir';
             'str',     'str',     'str',     'str',     'str',     'str',     'str';
             'req',     'nrq',     'nrq',     'nrq',     'nrq',     'nrq',     'nrq'};
         
% List parameters
param.list = {'motl_name', 'tomolist_name', 'wedgelist_name';
              'str',       'str',           'str';
              'req',       'nrq',           'nrq'};


% Subtomogram parameters
param.extract = {'subtomo_name', 'boxsize', 'pixelsize', 'output_format';
                 'str',          'num',     'num',       'str';
                 'req',          'req',     'nrq',       'nrq'};
             
% Other parameters
param.other = {'read_mode', 'output_pixelsize';
               'str',       'num';
               'nrq',       'nrq'};
               
             
           
           
           
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




