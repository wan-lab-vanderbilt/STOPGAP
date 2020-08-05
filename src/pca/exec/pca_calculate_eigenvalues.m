function pca_calculate_eigenvalues(p,o,s,idx)
%% pca_calculate_eigenvalues
% Calculate eigenvalues from eigenfactors and pre-rotated volumes.
%
% WW 06-2019

%% Initialize

% Initialize volumes
v = struct();
v = initialize_eigenval_volumes(p,o,s,idx,v);
v = initialize_ref_for_pca(p,o,s,v,idx);


% Load real-space mask
mask = read_vol(s,p(idx).rootdir,[o.maskdir,p(idx).mask_name]);
v.m_idx = mask > 0;
v.m_val = mask(v.m_idx);
clear mask

% Generate bandpass filters
f = generate_pca_bpf(o,s);


% Parallel job parameters
[p_start, p_end] = job_start_end(o.n_subtomos, o.n_cores, o.procnum);
n_p_subtomo = p_end - p_start + 1;

% Initialize eigenvalue array
eigenvalues = zeros(n_p_subtomo,p(idx).n_eigs,o.n_filt,'single');

% Initialize status writing
status = fopen([p(idx).rootdir,o.commdir,'eigenvalprog_',num2str(o.procnum)],'w');

% Force subtomo data type
p(idx).data_type = 'subtomo';

%% Calculate eigenvalues

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',n_p_subtomo,s.counter_pct);

e = 1;  % Eigenvalue counter
for i = p_start:p_end
    
    % Read subtomogram
    subtomo_name = [o.rvoldir,'/',p(idx).rvol_name,'_',s.subtomo_num(o.subtomos(i)),s.vol_ext];
    subtomo = read_vol(s,p(idx).rootdir,subtomo_name);
    if sg_check_param(p(idx),'apply_laplacian')
        subtomo = del2(subtomo);
    end
    subtomo = fftn(subtomo);
    
    % Read filter
    filter_name = [o.rvoldir,p(idx).rwei_name,'_',s.subtomo_num(o.subtomos(i)),s.vol_ext];
    filter = read_vol(s,p(idx).rootdir,filter_name);

    for j = 1:o.n_filt
        
        % Prepare particle data
        part_data = pca_filter_and_prepare_data(subtomo,f.(['bpf_',num2str(j)]),ones(o.boxsize,'single'),v.m_idx,v.m_val,p(idx).data_type,v.ft_ref,filter);
        
        % Calculate eigenvalues
        for k = 1:p(idx).n_eigs
            
            % Filter eigenvector
            evec = real(ifftn(v.(['ft_',num2str(j),'_',num2str(k)]).*filter.*f.(['bpf_',num2str(j)])));
              
            % Parse eigenvector voxels
            eigen_data = evec(v.m_idx).*v.m_val;
            eigen_data = (eigen_data-mean(eigen_data(:)))./std(eigen_data(:));
            
            
            % Calculate eigenvalue
            eigenvalues(e,k,j) = sg_pearson_correlation(part_data,eigen_data);
            
            
        end
        
    end
    e = e+1;    % Increment eigenvalue counter
    
    % Write counter
    fprintf(status,'%s \n',num2str(o.subtomos(i)));
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',n_p_subtomo,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_p_subtomo),' subtomograms processed... ',rt_str]);
    end
    
end



%% Write outputs
    
% Close status
fclose(status);

% Write partial value lists
for i = 1:o.n_filt
    name = [o.tempdir,'/',p(idx).eigenval_name,'_',num2str(o.filtlist(i).filt_idx),'_',num2str(o.procnum),'.csv'];
    csvwrite([p(idx).rootdir,'/',name],eigenvalues(:,:,i));
end

% Write checkjob
% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_eigenval_',num2str(o.procnum)]);
disp([s.nn,'Parallel eigenvalue calculation completed!!!1!']);






