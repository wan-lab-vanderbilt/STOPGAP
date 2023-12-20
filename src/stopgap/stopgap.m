function stopgap(varargin)
%% stopgap
% Main function for running STOPGAP. This takes the initial parameters and
% check the parameter file type, then passes the information along to the
% proper STOPGAP task.
%
% WW 03-2021


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


