function f = initialize_subtomo_ctf_filtering(o,f,mode)
%% initialize_subtomo_ctf_filtering
% Initialize variables and arrays for generating 3D CTF filters.
%
% WW 06-2019

%% Check for supersampled averaging

% Check for super sampling
if sg_check_param(o,'avg_ss')
    ss = o.avg_ss > 1;
else
    ss = false;
end

if strcmp(mode,'avg') && ss
    
    % Use supersampled numbers
    boxsize = max(o.ss_boxsize);
    pixelsize = o.ss_pixelsize;
    cen = o.ss_cen;

    % Size for full CTF arrays
    f.full_size = max([o.wedgelist.tomo_x,o.wedgelist.tomo_y,o.wedgelist.tomo_z])*o.avg_ss;        
    
else
    
    % Use normal numbers
    pixelsize = o.pixelsize;    
    if sg_check_param(o,'fcrop')
        boxsize = max(o.full_boxsize);
    else
        boxsize = max(o.boxsize);
    end
    cen = floor(boxsize/2)+1;
    
    % Size for full CTF arrays
    f.full_size = max([o.wedgelist.tomo_x,o.wedgelist.tomo_y,o.wedgelist.tomo_z]);       
    
end

%% Initialize!!!

% Full image frequencies
f.freq_1d_full = single(sg_frequencyarray(zeros(1,f.full_size),pixelsize));

% Fourier cropped frequencies
freq_1d_crop = single(sg_frequencyarray(zeros(1,boxsize),pixelsize));
if sg_check_param(o,'fcrop')
    f.freq_1d_crop = freq_1d_crop(cen:(cen+floor(max(o.boxsize)/2)-1));
else
    f.freq_1d_crop = freq_1d_crop(cen:boxsize);
end
    

% Intialize Fourier cropping array
f.fcrop_idx = calculate_1d_crop_idx(f.full_size,boxsize);


