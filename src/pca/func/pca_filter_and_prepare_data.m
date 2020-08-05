function data = pca_filter_and_prepare_data(ft_vol,bpf,filter,m_idx,m_val,data_type,ft_ref,ref_filter)
%% pca_filter_and_prepare_data
% Perform calcualtions to filter, normalize, and otherwise generate the
% desired type of partcle data.
%
% WW 07-2019

%% Prepare data


% Filter and normalize subtomo
if any(strcmp(data_type,{'subtomo','wmd'}))
    
    % Filter subtomo
    fvol = real(ifftn(ft_vol.*bpf.*filter));

    % Parse data and mask
    data = fvol(m_idx).*m_val;    

    % Normalize data
    data = (data-mean(data(:)))./std(data(:));

end



switch data_type

    % Generate wedge masked difference 
    case 'wmd'

    % Filter reference
    fref = real(ifftn(ft_ref.*bpf.*filter.*ref_filter));    

    % Normalize linear reference data
    norm_ref = fref(m_idx).*m_val;
    norm_ref = (norm_ref - mean(norm_ref(:)))./std(norm_ref(:));

    % Generate wmd
    data = norm_ref - data;




    % Calculate amplitude-weighted phase difference
    case 'awpd'
        
        
        % Calcualte phase difference
        dphase = (exp(1i*angle(ft_ref.*ref_filter.*filter)) - exp(1i*angle(ft_vol.*filter)));

        % Generate vol
        diff = real(ifftn(abs(ft_vol.*filter).*bpf.*dphase));

        % Parse data
        data = diff(m_idx).*m_val;

        % Normalize data
        data = (data-mean(data(:)))./std(data(:));
end

end
