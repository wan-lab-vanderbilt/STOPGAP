function [parser_param,param] = sg_get_subtomo_input_arguments()
%% sg_get_input_arguments
% A function to return an array containing input arguments.
%
% WW 05-2018


%% Parameters
% Intialize parameter struct
param = struct();

% Directory parameters
param.dir = {'rootdir', 'tempdir', 'commdir', 'rawdir', 'refdir', 'maskdir', 'listdir', 'fscdir', 'subtomodir', 'metadir', 'specdir';
             'str',     'str',     'str',     'str',    'str',    'str',     'str',     'str',    'str',        'str',     'str';
             'req',     'nrq',     'nrq',     'nrq',    'nrq',    'nrq',     'nrq',     'nrq',    'nrq',        'nrq',     'nrq'};
         
% Iteration arguments
param.iter = {'subtomo_mode', 'startidx', 'iterations';
              'str',          'num',      'num';
              'req',          'req',      'nrq'};
        
% Motivelist/wedgelist parameters
param.list = {'motl_name', 'wedgelist_name', 'binning';
              'str',       'str',            'num';
              'req',       'req',            'req'};
          
% Volume parameters          
param.vol = {'ref_name',     'subtomo_name';
             'str',          'str';
             'req',          'req'};
             
         
% Mask filenames          
param.mask = {'mask_name', 'ccmask_name';
              'str',       'str';
              'nrq',       'nrq'};
          
% External filter filenames
param.ext_filter = {'ali_reffilter_name', 'ali_particlefilter_name', 'avg_reffilter_name', 'avg_particlefilter_name', 'reffiltertype', 'particlefiltertype';
                    'str',                'str',                     'str',                'str',                     'str',           'str';
                    'nrq',                'nrq',                     'nrq',                'nrq',                     'nrq',           'nrq'};
            
% Fourier transforms
param.fourier_param = {'ps_name', 'amp_name', 'specmask_name';
                       'str',     'str',      'str';
                       'nrq',     'nrq',      'nrq'};
            
% Alignment search parameters
param.search_type = {'search_mode', 'search_type';
                     'str',         'str';       
                     'nrq',         'nrq'};
param.euler = {'euler_axes','euler_1_incr','euler_1_iter','euler_2_incr','euler_2_iter','euler_3_incr','euler_3_iter';
               'str',       'num',         'num',         'num',         'num',         'num',         'num';
               'nrq',       'nrq',         'nrq',         'nrq',         'nrq',         'nrq',         'nrq'};         
param.cone = {'angincr','angiter','phi_angincr','phi_angiter','cone_search_type';
              'num',    'num',    'num',        'num',        'str';
              'nrq',    'nrq',    'nrq',        'nrq',        'nrq'};



% Scoring function
param.scoring = {'apply_laplacian','scoring_fcn';
                 'boo',            'str';
                 'nrq',            'nrq'};
            
% Bandpass parameters
param.bandpass = {'lp_rad', 'lp_sigma', 'hp_rad', 'hp_sigma';
                  'num',    'num',      'num',    'num';
                  'nrq',    'nrq',      'nrq',    'nrq'};  
              
% Otther filters
param.filters = {'calc_exp', 'calc_ctf', 'cos_weight',  'score_weight';
                 'boo',      'boo',      'num',         'num';
                 'nrq',      'nrq',      'nrq',         'nrq'};
              
% Other parameters              
param.other = {'symmetry', 'score_thresh', 'subset', 'avg_mode', 'ignore_halfsets', 'temperature', 'rot_mode', 'fthresh', 'avg_ss';
               'str',      'num',          'num',    'str',      'boo',             'num',         'str',      'num',     'boo';
               'nrq',      'nrq',          'nrq',    'nrq',      'nrq',             'nrq',         'nrq',      'nrq',     'nrq'};
           

           
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







           
