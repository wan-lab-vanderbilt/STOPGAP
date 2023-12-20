function [parser_param,param] = sg_get_tps_parameter_arguments()
%% sg_get_tps_parameter_arguments
% A function to return an array containing input arguments.
%
% WW 10-2022


%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tempdir', 'commdir', 'refdir', 'maskdir', 'listdir', 'subtomodir', 'specdir', 'metadir';
             'str',     'str',     'str',     'str',    'str',     'str',     'str',        'str',     'str';
             'req',     'nrq',     'nrq',     'nrq',    'nrq',     'nrq',     'nrq',        'nrq',     'nrq'};         
        
% List parameters
param.list = {'motl_name', 'radlist_name';
              'str',       'str';
              'req',       'req'};
          
% Volume parameters          
param.vol = {'subtomo_name',    'ps_name';
             'str',             'str';
             'req',             'req'};
             
         
% Mask filenames          
param.mask = {'mask_name';
              'str';
              'nrq'};                      
              
% Bandpass parameters
param.bandpass = {'lp_rad', 'lp_sigma', 'hp_rad', 'hp_sigma';
                  'num',    'num',      'num',    'num';
                  'nrq',    'nrq',      'nrq',    'nrq'};
              
% Other parameters              
param.other = {'tps_mode', 'symmetry', 'apply_laplacian', 'score_thresh';
               'str',      'str',      'boo',             'num';
               'req',      'nrq',      'nrq',             'nrq'};
           

           
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
           
% %% Write parameter names to text file
% 
% paramtxt = fopen('param.txt','w');
% for i = 1:size(parser_param,2)
%     fprintf(paramtxt,'%s\n',parser_param{1,i});
% end
% fclose(paramtxt);







           
