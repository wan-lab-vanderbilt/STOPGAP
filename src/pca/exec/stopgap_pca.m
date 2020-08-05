function stopgap_pca(rootdir,paramfilename,procnum,n_cores)
%% stopgap_pca
% Perform classification in STOPGAP using Principle Component Analysis and
% k-means clustering. 
%
% The overall PCA pipeline is defined by the parameter file; this is
% generated using the PCA parser. The param file will also contain boolean
% flags that decide if a computational step will be performed. 
%
% WW 05-2019


% % % % % % DEBUG
% rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/subtomo/mixedCTF/bin2/sg_0.7_ccmat_subtomo/';
% paramfilename = 'params/pca_param.star';
% procnum = '1';
% n_cores = 512;


%% Evaluate numeric inputs
if (ischar(procnum)); procnum=eval(procnum); end
if (ischar(n_cores)); n_cores=eval(n_cores); end

%% Initialize

% Intialize settings struct
s = struct();

% Initialize node name
s.nn = ['Node',num2str(procnum),': '];

disp([s.nn,'Initializing...']);

% Read parameter file
disp([s.nn,'Reading parameter file...']);
[p,idx] = update_pca_param(s,rootdir, paramfilename);
if isempty(idx)
    error([s.nn,'ACHTUNG!!! All jobs in .param file compelted!!!']);
end

% Read settings
disp([s.nn,'Reading settings...']);
s = sg_get_pca_settings(s,p(idx).rootdir,'pca_settings.txt');


% Initialize struct array to hold objects
o = struct();
o.procnum = procnum;
o.n_cores = n_cores;
o = sg_parse_pca_directories(p,o,s,idx);

% % Cleanup comm folder
% if o.procnum == 1
%     system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
% end


    
%% Perform task

run = true;
while run

    % Read input lists
    o = pca_read_lists(p,o,idx);        % Read motivelist and wedgelist
    o = get_subtomo_boxsize(p,o,s,idx);       % Get boxsize from subtomogram
    o = load_filter_list(p,o,s,idx);    % Read in filter list
    o = distribute_filter_jobs(o);  % Determine job parameters for filter-based jobs


    switch p(idx).pca_task

        % Pre-rotate volumes
        case 'rot_vol'
            calc_rot_vol(p,o,s,idx,paramfilename);
            

        % Calcualte CC-matrix
        case 'calc_ccmat'
            calc_ccmat(p,o,s,idx,paramfilename);    
            
            
        % Calculate PCA from CC-matrix
        case 'calc_pca_ccmat'
            calc_pca_ccmat(p,o,s,idx,paramfilename);
            

        % Calculate covariance matrix
        case 'calc_covar'
            calc_covar(p,o,s,idx,paramfilename);
            
        otherwise
            error([s.nn,'ACHTUNG!!! Unsupported PCA task!!!']);
        

    end

    % Update parameter file
    [p,idx] = update_pca_param(s,rootdir, paramfilename);
    if isempty(idx)
        run = false;
    end

end

end

%% Pre-rotate volumes
function calc_rot_vol(p,o,s,idx,paramfilename)

% Check commdir
if o.procnum==1
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_rotvol']);
end


% Start timing
t = struct();
t = processing_timer(t,'start',p,o,idx,'rotvol');

% Prerotate volumes
pca_prerotate_volumes(p,o,s,idx);

% Write timing
processing_timer(t,'end',p,o,idx,'rotvol');

% Wait for completion of alignment step
if o.procnum == 1
    complete_pca_prerotate(p,o,s,idx,paramfilename);
else
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_rotvol',s.wait_time);
end

end


%% Calculate CC-matrix
function calc_ccmat(p,o,s,idx,paramfilename)

% Check for defined parameter
if ~sg_check_param(p(idx),'ccmat_name')
    error([s.nn,'ACHTUNG!!! Cannot calculate CC-matrix!!! ccmat_name is undefined!!!']);
end

if o.procnum==1
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_ccmat_',num2str(idx)]);
end



%%%%% Pairwise calculations %%%%%

% Start timing
t = struct();
t = processing_timer(t,'start',p,o,idx,'p_ccmat');

% Calculate part of CC matrix
pca_calculate_ccmatrix(p,o,s,idx);

% Write timing
processing_timer(t,'end',p,o,idx,'p_ccmat');




%%%%% Compile matrices %%%%%

% Wait for completion of alignment step
if o.filt_job_core

    % Wait for parallel cores
    wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_ccmat',o.n_cores,s.wait_time);     

    % Start timing
    t = struct();
    t = processing_timer(t,'start',p,o,idx,'f_ccmat');

    % Assemble matrices
    pca_assemble_ccmatrix(p,o,s,idx);       

    % Write timing
    processing_timer(t,'end',p,o,idx,'f_ccmat');

    if o.procnum == 1
        complete_pca_ccmatrix(p,o,s,idx,paramfilename);     % Compile and cleanup task
    else
        wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_sg_pca_ccmat_',num2str(idx)],s.wait_time);
    end
else
    wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_sg_pca_ccmat_',num2str(idx)],s.wait_time);
end

end


%% Calculate PCA from CC-matrix
function calc_pca_ccmat(p,o,s,idx,paramfilename)


if o.procnum == 1
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenfactors*']);
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_pca']);
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_p_eigenvol*']);
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_f_eigenvol*']);
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenval*']);
end




%%%%% Calculate PCA and eigenfactors %%%%%
if o.filt_job_core
    pca_ccmat_calculate_eigenfactors(p,o,s,idx);
end
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_eigenfactors',o.n_filt,s.wait_time);




%%%%% Calculate eigenvectors %%%%%

% Start timing
t = struct();
t = processing_timer(t,'start',p,o,idx,'p_eigenvec');

% Parallel calculate eigenvectors
pca_calculate_eigenvectors_parallel(p,o,s,idx);

% Write timings
processing_timer(t,'end',p,o,idx,'p_eigenvec');



% Final calculate eigenvectors
if o.filt_job_core

    % Wait for parallel cores
    wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_p_eigenvec',o.n_cores,s.wait_time);     

    % Start timing
    t = struct();
    t = processing_timer(t,'start',p,o,idx,'f_eigenvec');

    % Final calculate eigenvectors
    pca_calculate_eigenvectors_final(p,o,s,idx);

    % Write timings
    processing_timer(t,'end',p,o,idx,'f_eigenvec');    % Write timing

end 


% Complete eigenvector calculation
if o.procnum == 1
    complete_eigenvector(p,o,s,idx,paramfilename);
else
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_eigenvec',s.wait_time);
end



%%%%% Calculate eigenvalues %%%%%

% Start timing
t = struct();
t = processing_timer(t,'start',p,o,idx,'eigenval');

% Parallel calculate eigenvectors
pca_calculate_eigenvalues(p,o,s,idx);

% Write timing
processing_timer(t,'end',p,o,idx,'eigenval');


% Complete eigenvalue calculation
if o.procnum == 1
    complete_eigenvalue(p,o,s,idx,paramfilename);
else
    wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_eigenval',s.wait_time);
end

end

%% Calculate covariance matrix
function calc_covar(p,o,s,idx,paramfilename)

% Check for defined parameter
if ~sg_check_param(p(idx),'covar_name')
    error([s.nn,'ACHTUNG!!! Cannot calculate covariance-matrix!!! covar_name is undefined!!!']);
end

if o.procnum==1
    system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_sg_pca_covar']);
end

% Start timing
t = struct();
t = processing_timer(t,'start',p,o,idx,'p_covar');

% Calculate part of covariance matrix
pca_calculate_covariance_matrix(p,o,s,idx);

% Write timing
processing_timer(t,'end',p,o,idx,'p_covar');% Write timing


% Wait for completion of alignment step
if o.filt_job_core
    
    % Wait for paralle jobs
    wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_pca_covar',o.n_cores,s.wait_time);      % Wait for parallel cores
    
    % Start timing
    t = struct();
    t = processing_timer(t,'start',p,o,idx,'f_covar');
    
    % Assemble matrices
    pca_assemble_covariance_matrix(p,o,s,idx);    
    
    % Write timing
    processing_timer(t,'end',p,o,idx,'f_covar');% Write timing
    
    if o.procnum == 1
        complete_pca_covariance_matrix(p,o,s,idx,paramfilename);     % Compile and cleanup task
    end
    
    
end
    
% Wait for job completion
wait_for_it([p(idx).rootdir,'/',o.commdir],'complete_sg_pca_covar',s.wait_time);

            
end


