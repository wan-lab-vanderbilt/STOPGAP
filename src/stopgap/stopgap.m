function stopgap(varargin)
%% stopgap
% Main function for running STOPGAP. This takes the initial parameters and
% check the parameter file type, then passes the information along to the
% proper STOPGAP task.
%
% WW 03-2021

% % % % DEBUG
% SLURM DEBUG
% varargin = {'rootdir', '/dors/wan_lab/home/wanw/research/HIV_testset/subset_from_scratch/shc_speed_test/crop_shc/bin2/', 'paramfilename', 'params/subtomo_param.star', 'procnum', '1', 'n_cores', '100', 'user_id', '1234', 'job_id', '123123', 'node_name', 'cn100', 'node_id', '1', 'n_nodes', '1', 'cpus_on_node' '8' 'local_id', '1' 'copy_local' '1'};
% MPI DEBUG
% varargin = {'rootdir', '/dors/wan_lab/home/wanw/research/HIV_testset/subset_from_scratch/subtomo/bin8_tm_tilesize_test/', 'paramfilename', 'params/tm_param.star', 'procnum', '1', 'n_cores', '20', 'user_id', '1234', 'node_name', 'cn100', 'n_nodes', '1', 'cpus_on_node' '20' 'local_id', '1' 'copy_local' '0'};

% %% Evaluate numeric inputs
% if (ischar(procnum)); procnum=eval(procnum); end
% if (ischar(n_cores)); n_cores=eval(n_cores); end


%% Parse inputs

% Parse input parameters
s = parse_stopgap_inputs(varargin{:});

% Initialize core name
s = initialize_core_name(s);
disp([s.cn,'STOPGAP loaded!!!']);

% Determine task
star_name = [s.rootdir,'/',s.paramfilename];
db_name = get_star_data_block(star_name); % Parse data block name from param file



%% Run task

switch db_name

    % Run subtomogram alignment/averaging
    case 'stopgap_subtomo_parameters'        
        stopgap_subtomo(s);

    case 'stopgap_extract_parameters'
        stopgap_extract_subtomos(s);

    % Run template matching
    case 'stopgap_tm_parameters'
        stopgap_template_match(s);

    % Run PCA
    case 'stopgap_pca_parameters'
        stopgap_pca(rootdir,paramfilename,procnum,n_cores);

    % Run variance map
    case 'stopgap_vmap_parameters'
        stopgap_vmap(rootdir,paramfilename, procnum, n_cores);

    % Run tube power spectrum
    case 'stopgap_tps_parameters'
        stopgap_tube_ps(s);

end


end


