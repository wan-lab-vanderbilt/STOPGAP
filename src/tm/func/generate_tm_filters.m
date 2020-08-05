function f = generate_tm_filters(p,o,s,idx)
%% generate_tm_filters
% Generate filters for template matching.
%
% WW 01-2019

%% Check for filters 

% Initialize struct
f = struct();

% Check for special reference filters
f.calc_ctf = false;
f.calc_exposure = false;
f.calc_cosine = false;


% Check for CTF calculation
if sg_check_param(p(idx),'calc_ctf')
    % Check for defocus in wedgelist
    if isfield(o.wedgelist,'defocus') && isfield(o.wedgelist,'pixelsize')     
        f.calc_ctf = true;       
    else
        error([s.nn,'ACHTUNG!!! Insufficent wedgelist information to calculate CTF filter!!!']);
    end          
end


% Check for exposure filter calculation
if sg_check_param(p(idx),'calc_exp')
    % Check for exposure filtering in wedgelist
    if isfield(o.wedgelist,'exposure') && isfield(o.wedgelist,'pixelsize') 
        f.calc_exposure = true;   
    else
        error([s.nn,'ACHTUNG!!! Insufficent wedgelist information to calculate exposure filter!!!']);
    end
end


    
% Calculate frequency array
if any([f.calc_ctf,f.calc_exposure])    

    if o.fcrop
        tmpl_size = o.full_tmpl_size;
    else
        tmpl_size = o.tmpl_size;
    end
    % Generate frequency array
    freq_array = sg_frequencyarray(zeros(tmpl_size,tmpl_size,tmpl_size),o.pixelsize);

    % Store frequency array
    f.freq_array = ifftshift(freq_array);
    if o.fcrop
        f.freq_array = crop_fftshifted_vol(f.freq_array,o.f_idx_tmpl);
    end

end

%% Initial binary filters

% Wedgelist index
f.wedge_idx = find([o.wedgelist.tomo_num] == p(idx).tomo_num);

% Calcualte binary mask, slice indices, and slice weights
f = generate_tm_wedgemask_slices(o,f);


% Set template and tile filters
f.tmpl_filt = f.bin_wedge.*o.tmpl_bpf;
f.tile_filt = f.tile_bin_wedge.*o.tile_bpf;


%% Apply other filters


% Refresh exposure filter
if f.calc_exposure
    
    
    % Generate filter
    f = generate_tm_exposure_filter(o,f);
    
    
    % Apply filter
    f.tmpl_filt = f.tmpl_filt.*f.exp_filt;    

end

% Generate CTF filter
if f.calc_ctf    
    
    % Calculate filter
    f = generate_tm_ctf_filter(o,f);
    
    % Apply CTF filter
    f.tmpl_filt = f.tmpl_filt.*f.ctf_filt;    

end











