function [parser_param,param] = sg_get_vmap_input_arguments()
%% sg_get_vmap_input_arguments
% A function to return an array containing variance map input arguments.
%
% WW 05-2019

%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tempdir', 'commdir', 'rawdir', 'refdir', 'maskdir', 'listdir', 'subtomodir', 'metadir';
             'str',     'str',     'str',     'str',    'str',    'str',     'str',     'str',         'str';
             'req',     'nrq',     'nrq',     'nrq',    'nrq',    'nrq',     'nrq',     'nrq',         'nrq'};


% Iteration arguments
param.iter = {'vmap_mode', 'iteration';
              'str',       'num';
              'req',       'nrq'};


% Motivelist/wedgelist parameters
param.list = {'motl_name', 'wedgelist_name', 'binning';
              'str',       'str',            'num';
              'req',       'req',            'req'};


% Volume parameters          
param.vol = {'ref_name', 'vmap_name', 'subtomo_name';
             'str',      'str',       'str';
             'req',      'req',       'req'};
             
         
% Mask filenames          
param.mask = {'mask_name';
              'str';
              'nrq'};

% Bandpass filter parameters
param.bpf = {'lp_rad', 'lp_sigma', 'hp_rad', 'hp_sigma';
             'num',    'num',      'num',    'num';
             'req',    'nrq',      'nrq',    'nrq'};

          
% Other parameters              
param.other = {'symmetry', 'score_thresh', 'fthresh';
               'str',      'num',         'num';
               'nrq',      'nrq',         'nrq'};         
             

           
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
