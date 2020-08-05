function v = refresh_ccmatrix_volumes(p,o,s,idx,v,pair)
%% refresh_ccmatrix_volumes
% Check pair ID's and referesh input volumes as necessary.
%
% WW 06-2019


%% Refresh volumes

for i = 1:2
    
    subtomo_num = o.subtomos(pair(i));
    
    % Refresh during ID mismatch
    if v.(char(64+i)).idx ~= subtomo_num        
        
        % Set new index
        v.(char(64+i)).idx = subtomo_num;
        
        % Load volume
        vol_name = [o.rvoldir,'/',p(idx).rvol_name,'_',num2str(subtomo_num,['%0',num2str(s.subtomo_digits),'i']),s.vol_ext];
        vol = read_vol(s,p(idx).rootdir,vol_name);
        
        % Check for laplacian
        if sg_check_param(p(idx),'apply_laplacian')
            vol = del2(vol);
        end
        
        % Store FT
        v.(char(64+i)).ft_subtomo = fftn(vol);
        
        % Randomize FT
        if sg_check_param(p(idx),'noise_corr')
            v.(char(64+i)).rand_ft = sg_randomize_phases(v.(char(64+i)).ft_subtomo,s.fourier_cutoff);
        end
        
        % Load filter
        filt_name = [o.rvoldir,'/',p(idx).rwei_name,'_',num2str(subtomo_num,['%0',num2str(s.subtomo_digits),'i']),s.vol_ext];
        v.(char(64+i)).filter = read_vol(s,p(idx).rootdir,filt_name);
        
    end
    
end
        
        
        




