function f = initialize_p_avg_filters(p,o,idx,mode)
%% intialize_filters
% A function to initialize the stopgap filter struct array.
%
% WW 05-2018

%% Initialize struct

% Initialize array
f = struct();

% Initial tomogram number
f.tomo = -1; % Loaded tomogram
f.subtomo = -1;
f.class = -1;

% Check for special reference filters
f.calc_ctf = false;
f.calc_exposure = false;
f.calc_sbw = false;     % Score based weighting
f.calc_cosine = false;


% Check for defocus in wedgelist
if isfield(o.wedgelist,'defocus') && isfield(o.wedgelist,'pixelsize') 
    if isfield(p(idx),'calc_ctf')
        if p(idx).calc_ctf
            f = initialize_ctf_filtering(o,f,mode);
            f.calc_ctf = true;   
        end  
    else
        f = initialize_ctf_filtering(o,f,mode);
        f.calc_ctf = true;  % If not a parameter, filter if possible
    end
end

% Check for exposure filtering in wedgelist
if isfield(o.wedgelist,'exposure') && isfield(o.wedgelist,'pixelsize') 
    if isfield(p(idx),'calc_exp')
        if p(idx).calc_exp
            f.calc_exposure = true;   
        end  
    else
        f.calc_exposure = true;   % If not a parameter, filter if possible
    end
end

% Check for score-based weighting
if isfield(p(idx),'score_weight') && strcmp(mode,'avg')
    if (p(idx).score_weight < 1) && (p(idx).score_weight > 0)
        f.calc_sbw = true;
    end
end
        

% Calcualte frequency array
if any([f.calc_ctf,f.calc_exposure,f.calc_sbw])
    f = generate_frequency_array(o,f,mode);
end


% Calculate SNR filter
if isfield(p(idx),'snr_weight') && strcmp(mode,'ali')
    if p(idx).snr_weight   
        f.snr_weight = true;
        if ~isfield(f,'ssnr')
            f = snr_weighting(p,idx,f,mode);
        end 
    end    
end

    
% Fourier shell normalization
if sg_check_param(p(idx),'fs_norm') && strcmp(mode,'ali')
    f.fs_norm = true;
    f.fs_norm_mode = p(idx).fs_norm;    
end


% Cosine filter
if sg_check_param(p(idx),'cos_weight')
    if p(idx).cos_weight > 0
        f.calc_cosine = true; 
    end
end

    












