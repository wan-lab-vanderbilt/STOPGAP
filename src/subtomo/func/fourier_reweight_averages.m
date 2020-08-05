function v = fourier_reweight_averages(p,o,v,m,idx)
%% fourier_reweight_averages
% Reweight averaged volumes using Fourier weighting filter. 
%
% If dynamic range is beyond a given cutoff, a warning file is written out.
%
% WW 06-2019

%% Fourier reweight averages

% Loop through halfsets
for i = 1:2
    
    % Apply lowpass filter
    wfilt = ifftshift(v.(v.wfilt_names{i})).*m.lpf;
    
    % Determine non-zero indices
    nz_idx = wfilt(:) > 0;
    
    % Determine dynamic range
    max_val = max(wfilt(nz_idx));
    min_val = min(wfilt(nz_idx));
    d_range = max_val/min_val;
    
    % Check range
    if d_range > m.fthresh
        
        % Issue warning
        warn_name = [o.refdir,'/warning_',v.out_ref_names{i},'.txt'];
        issue_fthresh_warning(p(idx).rootdir,warn_name,d_range,m.fthresh);
        
        % Find voxels to threshold
        t_val = max_val/m.fthresh;
        t_idx = (wfilt <= t_val) & reshape(nz_idx,size(wfilt));
        
        % Threshold filter
        wfilt(t_idx) = t_val;
        
    end
    
    % Generate filter
    wfilt(nz_idx) = 1./wfilt(nz_idx);
    
    % Reweight average
    v.(v.ref_names{i}) = real(ifftn(fftn(v.(v.ref_names{i}).*m.cube_mask).*wfilt));
    
    
    
    % Reweight powerspec
    if isfield(v,'ps_names')
        v.(v.ps_names{i}) = real(v.(v.ps_names{i}).*wfilt);
    end
    
end
    
    
    
    



