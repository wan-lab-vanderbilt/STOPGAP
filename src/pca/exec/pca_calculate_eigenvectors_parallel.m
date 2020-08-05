function pca_calculate_eigenvectors_parallel(p,o,s,idx)
%% pca_calculate_eigenvectors_parallel
% Calcualte eigenvectors from eigenfactors and pre-rotated volumes.
%
% WW 06-2019

%% Initialize
disp([s.nn,'Calculating eigenvectors in parallel...']);

% Generate bandpass filters
f = generate_pca_bpf(o,s);


% Initialize volumes for averages
for i = 1:o.n_filt
    for j = 1:p(idx).n_eigs
        v.(['eig_',num2str(i),'_',num2str(j)]) = zeros(o.boxsize,'single');
        v.(['wei_',num2str(i),'_',num2str(j)]) = zeros(o.boxsize,'single');
    end
end

% Initialize reference (for WMD or AWPD)
v = initialize_ref_for_pca(p,o,s,v,idx);

% Load real-space mask
mask = read_vol(s,p(idx).rootdir,[o.maskdir,p(idx).mask_name]);
v.m_idx = mask > 0;
v.m_val = mask(v.m_idx);

% Read eigenvalues
eigenfac = zeros(o.n_subtomos,p(idx).n_eigs,o.n_filt,'single');
for i = 1:o.n_filt
    ef_name = [o.pcadir,'/',p(idx).eigenfac_name,'_',num2str(o.filtlist(i).filt_idx),'.csv'];
    eigenfac(:,:,i) = dlmread([p(idx).rootdir,'/',ef_name]);
end

% Parallel job parameters
[p_start, p_end] = job_start_end(o.n_subtomos, o.n_cores, o.procnum);
n_p_subtomo = p_end - p_start + 1;

% Initialize status writing
status = fopen([p(idx).rootdir,o.commdir,'eigenvecprog_',num2str(o.procnum)],'w');


%% Generate eigenvectors

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',n_p_subtomo,s.counter_pct);

for i = p_start:p_end
    
    % Read volume
    rvol_name = [o.rvoldir,'/',p(idx).rvol_name,'_',num2str(o.subtomos(i)),s.vol_ext];
    vol = read_vol(s,p(idx).rootdir,rvol_name);
    if sg_check_param(p(idx),'apply_laplacian') % Calculate laplacian
        vol = del2(vol);
    end
    vol = fftn(vol);
    
    % Read weight
    rwei_name = [o.rvoldir,'/',p(idx).rwei_name,'_',num2str(o.subtomos(i)),s.vol_ext];
    wei = read_vol(s,p(idx).rootdir,rwei_name);
    
    % Loop through filters
    for j = 1:o.n_filt       
        
        % Prepare volume
        rvol = pca_filter_and_prepare_volume(vol,f.(['bpf_',num2str(j)]),ones(o.boxsize,'single'),v.m_idx,v.m_val,p(idx).data_type,v.ft_ref,wei);
%         rvol = zeros(o.boxsize,'single');
%         rvol(v.m_idx) = rvol_data;
%         clear rvol_data
        
        
        % Loop through eigenvectors
        for k = 1:p(idx).n_eigs
            
            % Perform weighted sum
            e_field = ['eig_',num2str(j),'_',num2str(k)];
            v.(e_field) = v.(e_field) + (rvol.*eigenfac(i,k,j));
            w_field = ['wei_',num2str(j),'_',num2str(k)];
            v.(w_field) = v.(w_field) + (abs(wei).*eigenfac(i,k,j));
            
        end
        
        clear rvol
    end
    clear vol wei

    
     % Write counter
    fprintf(status,'%s \n',num2str(o.subtomos(i)));
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',n_p_subtomo,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_p_subtomo),' volumes processed... ',rt_str]);
    end
    
end


%% Write outputs
    
% Close status
fclose(status);


% Write volumes
for i = 1:o.n_filt
    for j = 1:p(idx).n_eigs
        
        % Write volume
        name = [o.tempdir,'/',p(idx).eigenvol_name,'_',num2str(i),'_',num2str(j),'_',num2str(o.procnum),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,v.(['eig_',num2str(i),'_',num2str(j)]));
        
        % Write filter
        name = [o.tempdir,'/wei_',num2str(i),'_',num2str(j),'_',num2str(o.procnum),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,v.(['wei_',num2str(i),'_',num2str(j)]));
        
    end
end


% Write checkjob
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_p_eigenvec_',num2str(o.procnum)]);
disp([s.nn,'Parallel eigenvector calculation complete!!!']);






