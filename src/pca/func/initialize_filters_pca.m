function f = initialize_filters_pca(p,o,mode)
%% initialize_filters_pca
% A function to initialize the stopgap filter struct array for prerotated
% PCA calculation.
%
% WW 05-2019

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
f.snr_weight = false;
f.fs_norm = false;
f.calc_cosine = false;


% Check for defocus in wedgelist
if isfield(o.wedgelist,'defocus') && isfield(o.wedgelist,'pixelsize') 
    if isfield(p,'calc_ctf')
        if p.calc_ctf
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
    if isfield(p,'calc_exp')
        if p.calc_exp
            f.calc_exposure = true;   
        end  
    else
        f.calc_exposure = true;   % If not a parameter, filter if possible
    end
end


% Calcualte frequency array
if any([f.calc_ctf,f.calc_exposure,f.calc_sbw])
    f = generate_frequency_array(o,f,mode);
end











