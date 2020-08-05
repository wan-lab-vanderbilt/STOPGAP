function final_vmap = fourier_reweight_vmaps(p,o,idx,class,vmap,wei,m)
%% fourier_reweight_vmaps
% Reweight averaged volumes using Fourier weighting filter. 
%
% If dynamic range is beyond a given cutoff, a warning file is written out.
%
% WW 06-2019

%% Fourier reweight averages


% Apply lowpass filter
wfilt = ifftshift(wei).*m.lpf;

% Determine non-zero indices
nz_idx = wfilt(:) > 0;

% Determine dynamic range
max_val = max(wfilt(nz_idx));
min_val = min(wfilt(nz_idx));
d_range = max_val/min_val;

% Check range
if d_range > m.fthresh

    % Issue warning
    switch p(idx).vmap_mode
        case 'singleref'
            warn_name = [o.refdir,'/warning_',p(idx).vmap_name,'_',num2str(p(idx).iteration),'.txt'];
        case 'multiclass'
            warn_name = [o.refdir,'/warning_',p(idx).vmap_name,'_',num2str(p(idx).iteration),'_',num2str(class),'.txt'];
    end    
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
final_vmap = real(ifftn(fftn(vmap.*m.cube_mask).*wfilt));


    

    
    
    
    



