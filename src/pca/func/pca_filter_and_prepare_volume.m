function fvol = pca_filter_and_prepare_volume(ft_vol,bpf,filter,m_idx,m_val,data_type,ft_ref,ref_filter)
%% pca_filter_and_prepare_volume
% Perform calcualtions to filter, normalize, and otherwise generate the
% desired type of partcle data. This applies the masking locally, but keeps
% the whole volume.
%
% WW 07-2019

%% Prepare volume

% Filter subtomo
fvol = real(ifftn(ft_vol.*bpf.*filter));


% Filter and normalize subtomo
if any(strcmp(data_type,{'subtomo','wmd'}))

    % Normalize data under mask
    fvol = (fvol-mean(fvol(m_idx).*m_val))./std(fvol(m_idx).*m_val);

end



switch data_type

    % Generate wedge masked difference 
    case 'wmd'

    % Filter reference
    fref = real(ifftn(ft_ref.*bpf.*filter.*ref_filter));    

    % Normalize linear reference data
    fref = (fref - mean(fref(m_idx).*m_val))./std(fref(m_idx).*m_val);

    % Generate wmd
    fvol = fref - fvol;




    % Calculate amplitude-weighted phase difference
    case 'awpd'

        % Calcualte phase difference
        dphase = (exp(1i*angle(ft_ref)) - exp(1i*angle(fvol)));

        % Generate vol
        fvol = real(ifftn(abs(fvol).*bpf.*dphase));


        % Normalize data
        fvol = (fvol-mean(fvol(m_idx).*m_val))./std(fvol(m_idx).*m_val);
end

end
