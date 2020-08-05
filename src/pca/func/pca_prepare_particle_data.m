function data = pca_prepare_particle_data(p,v,idx,f,bpf_idx)
%% pca_prepare_particle_data
% Prepare a subtomogram for PCA analysis. Returned is the masked,
% normalized region of a filtered particle. The particle can be represented
% as the grey-value data, a 'wedge-masked difference (wmd)', or an
% amplitude-weighted phase difference (awpd). 
%
% WW 06-2019

%% Check check

% Check for reference
if isfield(v,'ft_ref')
    ft_ref = v.ft_ref;
else
    ft_ref = [];
end


%% Prepare data

% Initialize data struct
data = struct();

% Loop through A and B
for i = 1:2
    
    % Check for reference
    if isfield(v,'ft_ref')
        ref_filter = v.(char(64+i)).filter;
    else
        ref_filter = [];
    end
    
    
    % Prepare data
    data.(char(64+i)) = pca_filter_and_prepare_data(v.(char(64+i)).ft_subtomo,...
                                                f.(['bpf_',num2str(bpf_idx)]),...
                                                v.(char(67-i)).filter,...
                                                v.m_idx, v.m_val,...
                                                p(idx).data_type,ft_ref,ref_filter);
    
    % Prepare phase randomized data
    if sg_check_param(p(idx),'noise_corr')
        data.([char(64+i),'_rand']) = pca_filter_and_prepare_data(v.(char(64+i)).rand_ft,...
                                                              f.(['bpf_',num2str(bpf_idx)]),...
                                                              v.(char(67-i)).filter,...
                                                              v.m_idx, v.m_val,...
                                                              p(idx).data_type,ft_ref,ref_filter);
    end
    
end


end



