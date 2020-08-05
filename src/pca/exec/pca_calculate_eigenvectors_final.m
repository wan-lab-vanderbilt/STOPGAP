function pca_calculate_eigenvectors_final(p,o,s,idx)
%% pca_calculate_eigenvectors_final
% Take the parallel eigenvector outputs, sum them, and apply Fourier
% weighting to generate the final eigenvectors. 
%
% Parallelization is such that each core processes all eigenvectors from a
% given bandpass filter.
%
% WW 06-2019

%% Initialize
disp([s.nn,'Calculating final eigenvectors...']);


% Generate bandpass filters
f = generate_pca_bpf(o,s);


% Initialize volumes for sums
v = struct();
for i = 1:p(idx).n_eigs
    v.(['eig_',num2str(i)]) = zeros(o.boxsize,'single');
    v.(['wei_',num2str(i)]) = zeros(o.boxsize,'single');
end

% Check Fourier threshold
if sg_check_param(p(idx),'fthresh')
    fthresh = p(idx).fthresh;
else
    fthresh = s.fthresh;
end

% Real space mask to prevent edge artifacts
cube_mask = sg_cube_mask(o.boxsize,3);




%% Sum volumes
disp([s.nn,'Summing volumes...']);

% Loop through filter jobs
for i = o.filt_jobs
    
    % Load eigenfactors
    ef_name = [o.pcadir,'/',p(idx).eigenfac_name,'_',num2str(o.filtlist(i).filt_idx),'.csv'];
    eigenfac = dlmread([p(idx).rootdir,'/',ef_name]);
    
    
    % Loop through eigenvectors
    for j = 1:p(idx).n_eigs

        % Sum partial sums
        for k = 1:o.n_cores

            % Sum volume
            name = [o.tempdir,'/',p(idx).eigenvol_name,'_',num2str(i),'_',num2str(j),'_',num2str(k),s.vol_ext];
            v.(['eig_',num2str(j)]) = v.(['eig_',num2str(j)]) + read_vol(s,p(idx).rootdir,name);
            
            % Sum weights
            name = [o.tempdir,'/wei_',num2str(i),'_',num2str(j),'_',num2str(k),s.vol_ext];
            v.(['wei_',num2str(j)]) = v.(['wei_',num2str(j)]) + read_vol(s,p(idx).rootdir,name);

        end
        
        % Divide to get averages
        total_weight = sum(abs(eigenfac(:,j)));
        v.(['eig_',num2str(j)]) = v.(['eig_',num2str(j)])./total_weight;
        v.(['wei_',num2str(j)]) = v.(['wei_',num2str(j)])./total_weight;
        
        
        
        %%%%% Generate Fourier reweighting filters %%%%%
    
        % Apply lowpass filter
        wfilt = f.(['bpf_',num2str(i)]).*v.(['wei_',num2str(j)]);

        % Determine non-zero indices
        nz_idx = wfilt > 0;

        % Determine dynamic range
        max_val = max(wfilt(nz_idx));
        min_val = min(wfilt(nz_idx));
        d_range = max_val/min_val;

        % Check range
        if d_range > fthresh

            % Issue warning
            warn_name = [o.pcadir,'/warning_eigenvolume_',num2str(o.filtlist(i).filt_idx),'_',num2str(j),'.txt'];
            issue_fthresh_warning(p(idx).rootdir,warn_name,d_range,fthresh);

            % Find voxels to threshold
            t_val = max_val/fthresh;
            t_idx = (wfilt <= t_val) & nz_idx;

            % Threshold filter
            wfilt(t_idx) = t_val;

        end

        % Generate filter
        wfilt(nz_idx) = 1./wfilt(nz_idx);




        %%%%% Apply filter %%%%%      
        v.(['eig_',num2str(j)]) = real(ifftn(fftn(v.(['eig_',num2str(j)]).*cube_mask).*wfilt));
        
    end
    
end



%% Write outputs
disp([s.nn,'Writing outputs...']);

% Write output volumes
for i = o.filt_jobs
    for j = 1:p(idx).n_eigs

        name = [o.pcadir,'/',p(idx).eigenvol_name,'_',num2str(o.filtlist(i).filt_idx),'_',num2str(j),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,v.(['eig_',num2str(j)]));
        
    end
    
end

% Write checkjob
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_f_eigenvec_',num2str(o.procnum)]);
disp([s.nn,'Final eigenvector calculation complete!!!']);


