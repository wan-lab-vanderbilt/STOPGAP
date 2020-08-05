function f = generate_subtomo_frequency_array(o,f,mode)
%% generate_frequency_array
% A function to generate a frequency array. This will be used for further
% calculations such as CTF filters.
%
% WW 01-2018

%% Check check

% Check boxsize
if strcmp(mode,'ali')
    if o.fcrop
        boxsize = o.full_boxsize;
    else
        boxsize = o.boxsize;
    end
    pixelsize = o.pixelsize;
    
elseif strcmp(mode,'avg')
    
    if sg_check_param(o,'avg_ss')
        boxsize = o.ss_boxsize;
        pixelsize = o.ss_pixelsize;
        
    else
        boxsize = o.boxsize;
        pixelsize = o.pixelsize;
    end
    
end

%% Calcuate and return array

% Generate frequency array
freq_array = sg_frequencyarray(zeros(boxsize,'single'),pixelsize);

% Check for return type
if strcmp(mode,'ali')
    f.freq_array = ifftshift(freq_array);
    if o.fcrop
        f.freq_array = fcrop_fftshifted_vol(f.freq_array,o.f_idx);
    end
elseif strcmp(mode,'avg')
    f.freq_array = single(freq_array);
end





