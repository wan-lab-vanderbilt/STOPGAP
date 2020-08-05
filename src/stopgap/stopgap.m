function stopgap(rootdir,paramfilename, procnum, n_cores, varargin)
%% stopgap
% Main function for running STOPGAP. This takes the initial parameters and
% check the parameter file type, then passes the information along to the
% proper STOPGAP task.
%
% WW 06-2019

% % % % % DEBUG
% rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/tm/sg_0.7/';
% paramfilename = 'params/tm_param.star';
% procnum = '1';
% n_cores = '400';


%% Evaluate numeric inputs
if (ischar(procnum)); procnum=eval(procnum); end
if (ischar(n_cores)); n_cores=eval(n_cores); end

%% Determine task

% Parse data block name from param file
star_name = [rootdir,'/',paramfilename];
db_name = get_star_data_block(star_name);


%% Run task

switch db_name
    
    % Run subtomogram alignment/averaging
    case 'stopgap_subtomo_parameters'        
        stopgap_subtomo(rootdir,paramfilename, procnum, n_cores);
        
        
    % Run template matching
    case 'stopgap_tm_parameters'
        stopgap_template_match(rootdir,paramfilename, procnum, n_cores);
        
    % Run PCA
    case 'stopgap_pca_parameters'
        stopgap_pca(rootdir,paramfilename,procnum,n_cores);

    % Run variance map
    case 'stopgap_vmap_parameters'
        stopgap_vmap(rootdir,paramfilename, procnum, n_cores);
        
end

end


