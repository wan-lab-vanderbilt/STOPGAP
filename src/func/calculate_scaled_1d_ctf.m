function f = calculate_scaled_1d_ctf(o,f,defocii,mode)
%% calculate_scaled_1d_ctf
% Calculate 1D ctf arrays for the calculation of 3D ctf filters.
%
% WW 08-2018

%% Parse CTF parameters

% Parse defocii
n_ang = numel(defocii);

% Parse phase shift
if ~isfield(o.wedgelist(f.wedge_idx),'pshift')
    pshift = zeros(n_ang,f.full_size);
else
    pshift = repmat([o.wedgelist(f.wedge_idx).pshift],[1,f.full_size]);
end

% Parse microscope parameters
famp = o.wedgelist(f.wedge_idx).amp_contrast;
cs = o.wedgelist(f.wedge_idx).cs;
evk = o.wedgelist(f.wedge_idx).voltage;


%% Check for supersampling

% Check for super sampling
if sg_check_param(o,'avg_ss')
    ss = o.avg_ss > 1;
else
    ss = false;
end


if strcmp(mode,'avg') && ss
    boxsize = max(o.ss_boxsize);
else
    
    if sg_check_param(o,'fcrop')
        boxsize = max(o.full_boxsize);
    else
        boxsize = max(o.boxsize);
    end
end
cen = floor(boxsize/2)+1;

%% Calculate CTFs

% Calculate full size CTF
full_ctf = abs(sg_ctf(repmat(defocii,[1,f.full_size]),pshift,famp,cs,evk,repmat(f.freq_1d_full,[n_ang,1])));

% Fourier crop CTFs
full_ctf = fft(full_ctf,[],2);
crop_ctf = reshape(full_ctf(repmat(f.fcrop_idx,[n_ang,1])),n_ang,boxsize).*(boxsize/f.full_size);
crop_ctf = real(ifft(crop_ctf,[],2));

% Crop one side of the CTF
if sg_check_param(o,'fcrop')
    crop_end = cen + floor(max(o.boxsize)/2) - 1;
    f.crop_ctf = crop_ctf(:,cen:crop_end);
else
    f.crop_ctf = crop_ctf(:,cen:boxsize);
end



