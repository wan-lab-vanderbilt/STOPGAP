function pca_calculate_covariance_matrix(p,o,s,idx)
%% pca_calculate_covariance_matrix
% Used to assemble a covariance matrix. The covariance matrix contains data
% from each subtomogram, with voxel data on the rows and data from each
% subtomogram on each column. The voxels that are used are those that are
% within the classification mask.
%
% Voxel data can be three things: 
%   1: Taken directly from the rotated subtomograms
%   2: 'wedge-masked differences', a la John Heumann
%   3: 'Amplitude-weighted phase differences', which are a modified version
%   of Ben Himes's approach. In this approach, the amplitudes are the
%   transfer function derrived from first principles (i.e. the reference
%   missing-wedge filters).
%
% Data is also bandpass filtered as defined by the filter list.
%
% WW 06-2019

%% Initialize

% Initialize reference
v = struct();
v = initialize_ref_for_pca(p,o,s,v,idx);

% Load real-space mask
mask = read_vol(s,p(idx).rootdir,[o.maskdir,p(idx).mask_name]);
v.m_idx = mask > 0;
v.m_val = mask(v.m_idx);
n_vox = sum(v.m_idx(:));
clear mask

% Generate bandpass filters
f = generate_pca_bpf(o,s);

% Parallel job parameters
[p_start, p_end] = job_start_end(o.n_subtomos, o.n_cores, o.procnum);
n_p_subtomo = p_end - p_start + 1;


% Initialize covariance arrays
covar = zeros(n_vox,n_p_subtomo,o.n_filt,'single');


% Initialize status writing
status = fopen([p(idx).rootdir,o.commdir,'covarprog_',num2str(o.procnum)],'w');

%% Fill covariance matrix


% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',n_p_subtomo,s.counter_pct);

n = 1;
% Loop through subtomograms
for i = p_start:p_end
    
    
    % Read subtomogram
    subtomo_name = [o.rvoldir,'/',p(idx).rvol_name,'_',s.subtomo_num(o.subtomos(i)),s.vol_ext];
    subtomo = read_vol(s,p(idx).rootdir,subtomo_name);
    if sg_check_param(p(idx),'apply_laplacian')
        subtomo = del2(subtomo);
    end
    subtomo = fftn(subtomo);
    
    % Read filter
    filter_name = [o.rvoldir,'/',p(idx).rwei_name,'_',s.subtomo_num(o.subtomos(i)),s.vol_ext];
    filter = read_vol(s,p(idx).rootdir,filter_name);
    
    
    % Loop through filters
    for j = 1:o.n_filt
        
        % Prepare and store particle data
        covar(:,n,j) = pca_filter_and_prepare_data(subtomo,f.(['bpf_',num2str(j)]),ones(o.boxsize,'single'),v.m_idx,v.m_val,p(idx).data_type,v.ft_ref,filter);

        
    end
        
    % Increment counter
    n = n+1;
    
    % Write counter
    fprintf(status,'%s \n',num2str(i));
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',n_p_subtomo,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_p_subtomo),' volumes processed... ',rt_str]);
    end
    
end



                
%% Write outputs

% Close status
fclose(status);

% Write CC-array
for i = 1:o.n_filt
    covar_name = [o.tempdir,'/',p(idx).covar_name,'_',num2str(o.procnum),'_',num2str(i),s.vol_ext];
    write_vol(s,o,p(idx).rootdir,covar_name,covar(:,:,i));
end

% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_covar_',num2str(o.procnum)]);

 
        
    














