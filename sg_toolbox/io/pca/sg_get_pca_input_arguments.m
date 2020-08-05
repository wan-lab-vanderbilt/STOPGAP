function [parser_param,param] = sg_get_pca_input_arguments()
%% sg_get_pca_input_arguments
% A function to return an array containing variance map input arguments.
%
% WW 05-2019

%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tempdir', 'commdir', 'rawdir', 'refdir', 'maskdir', 'listdir', 'subtomodir', 'rvoldir', 'pcadir', 'metadir';
             'str',     'str',     'str',     'str',    'str',    'str',     'str',     'str',        'str',     'str',    'str';
             'req',     'nrq',     'nrq',     'nrq',    'nrq',    'nrq',     'nrq',     'nrq',        'nrq',     'nrq',    'nrq'};


% Iteration arguments
param.iter = {'iteration';
              'num';
              'req'};


% Motivelist/wedgelist parameters
param.list = {'motl_name', 'wedgelist_name', 'binning';
              'str',       'str',            'num';
              'req',       'req',            'req'};


% Volume parameters          
param.vol = {'ref_name', 'subtomo_name', 'rvol_name', 'rwei_name';
             'str',      'str',          'str',       'str';
             'req',      'req',          'req',       'req'};
             
         
% Mask filenames          
param.mask = {'mask_name';
              'str';
              'nrq'};
          
% PCA parameters
param.pca = {'pca_task', 'filtlist_name', 'ccmat_name', 'covar_name', 'data_type', 'n_eigs', 'eigenvol_name', 'eigenfac_name', 'eigenval_name';
             'str',      'str',           'str',        'str',        'str',       'num',    'str',           'str',           'str';
             'req',      'req',           'nrq',        'nrq',        'req',       'req',    'req',           'req',           'req'};
             

              
% Other parameters              
param.other = {'apply_laplacian', 'noise_corr', 'symmetry', 'fthresh';
               'boo',             'boo',        'str',      'num';
               'nrq',             'nrq',        'req',      'nrq'};         
             

           
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
