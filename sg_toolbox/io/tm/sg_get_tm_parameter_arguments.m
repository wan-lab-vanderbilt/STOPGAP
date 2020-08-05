function [parser_param,param] = sg_get_tm_parameter_arguments()
%% get_tm_parameter_arguments
% Reutrn arguments for STOPGAP Template Matching parameters.
%
% WW 01-2019


%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tempdir', 'commdir', 'tmpldir', 'maskdir', 'listdir', 'mapdir', 'metadir';
             'str',     'str',     'str',     'str',     'str',     'str',     'str',    'str';
             'req',     'nrq',     'nrq',     'nrq',     'nrq',     'nrq',     'nrq',    'nrq'};
         
% List parameters
param.list = {'wedgelist_name', 'tomolist_name', 'tlist_name', 'tilelist_name';
              'str',            'str',           'str',        'str';
              'req',            'req',           'req',        'nrq'};
          
 % Volume parameters          
param.vol = {'smap_name', 'omap_name', 'tmap_name';
             'str',       'str',       'str';
             'req',       'req',       'req'};
                     
          
% Bandpass parameters
param.bandpass = {'lp_rad', 'lp_sigma', 'hp_rad', 'hp_sigma';
                  'num',    'num',      'num',    'num';
                  'req',    'nrq',      'req',    'nrq'};     
              
% Other filter parameters
param.filter = {'calc_exp', 'calc_ctf';
                'boo',      'boo';
                'nrq',      'nrq'};

% Other parameters              
% param.other = {'binning', 'apply_laplacian', 'scoring_fcn', 'noise_corr';
%                'num',     'boo',             'str',         'num';
%                'req',     'nrq',             'nrq',         'nrq'};
param.other = {'binning', 'apply_laplacian', 'noise_corr';
               'num',     'boo',             'num';
               'req',     'nrq',             'nrq'};

           
% Tomo parameters
param.tomo = {'tomo_name', 'tomo_num', 'tomo_mask_name';
              'str',       'str',      'str';
              'nrq',       'nrq',      'nrq'};

           
           
           
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
         
