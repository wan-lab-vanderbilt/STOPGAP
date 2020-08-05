function pca_calculate_ccmatrix(p,o,s,idx)
%% pca_calculate_ccmatrix
% Calculate CC-matrices for each bandpass filter in the filter list. 
%
% Pairwise CCs are calculating using the pre-rotated filters and
% subtomograms.
%
% WW 06-2019

%% Initialize

% Initialize volumes
v = initialize_ccmatrix_volumes(p,o,idx);

% Initialize reference (for WMD or AWPD)
v = initialize_ref_for_pca(p,o,s,v,idx);


% Load real-space mask
mask = read_vol(s,p(idx).rootdir,[o.maskdir,p(idx).mask_name]);
v.m_idx = mask > 0;
v.m_val = mask(v.m_idx);
clear mask


% Initialize pairlist
pairs = intialize_pairlist(o,s);
n_pairs = size(pairs,1);


% Generate bandpass filters
f = generate_pca_bpf(o,s);

% Initialize CC array
cc_array = zeros(n_pairs,o.n_filt,'single');


% Initialize status writing
system(['rm -f ',p(idx).rootdir,o.commdir,'ccmatprog_',num2str(o.procnum)]);
status = fopen([p(idx).rootdir,o.commdir,'ccmatprog_',num2str(o.procnum)],'w');


%% Calculate CCs

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',n_pairs,s.counter_pct);

for i = 1:n_pairs
    
    % Refresh volumes
    v = refresh_ccmatrix_volumes(p,o,s,idx,v,pairs(i,:));
    
    % Calculate CCs
    for j = 1:o.n_filt
        
        % Prepare volumes
        data = pca_prepare_particle_data(p,v,idx,f,j);
        
        % Calculate CC
        if sg_check_param(p(idx),'noise_corr')
            cc = sg_pearson_correlation(data.A,data.B);
            ncc = sg_pearson_correlation(data.A_rand,data.B_rand);
            cc_array(i,j) = (cc-ncc)./(1-ncc);
        else
            cc_array(i,j) = sg_pearson_correlation(data.A,data.B);
        end
        
%         % Schmid-Booth correction factor
%         ov_sig = sum((v.A.filter(:).*v.B.filter(:).*f.(['bpf_',num2str(j)])(:)) > 0);   % Overlapping signal
%         t_sig = sum(f.(['bpf_',num2str(j)])(:) > 0);   % Total signal
%         frac_signal = ov_sig/t_sig;
%         cc_array(i,j) = cc_array(i,j)/frac_signal;
        
        
    end
    
    % Write counter
    fprintf(status,'%s \n',num2str(i));
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',n_pairs,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_pairs),' correlated... ',rt_str]);
    end
    
end


%% Write outputs

% Close status
fclose(status);

% Write CC-array
for i = 1:o.n_filt
    cc_name = [o.tempdir,'/ccarray_',num2str(o.procnum),'_',num2str(i),'.csv'];
    csvwrite([p(idx).rootdir,'/',cc_name],cc_array(:,i));
end

% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_ccmat_',num2str(o.procnum)]);



        
        
        



