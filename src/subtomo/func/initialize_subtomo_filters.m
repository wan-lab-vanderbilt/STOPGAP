function f = initialize_subtomo_filters(p,o,s,idx,mode)
%% initialize_subtomo_filters
% A function to initialize the stopgap filter struct array for subtomogram 
% averaging/alignment.
%
% WW 05-2018

%% Initialize struct

% Initialize array
f = struct();

% Initial tomogram number
f.tomo = -1; % Loaded tomogram
f.subtomo = -1;
f.class = -1;

%% Check filters

% Check for special reference filters
f.calc_ctf = false;
f.calc_exp = false;
f.calc_sbw = false;     % Score based weighting
f.calc_cosine = false;


% Check for defocus in wedgelist
if isfield(o.wedgelist,'defocus') && isfield(o.wedgelist,'pixelsize') % Check for required information
    
    if isfield(p(idx),'calc_ctf')   % Param-file setting overrides        
        if p(idx).calc_ctf
            f = initialize_subtomo_ctf_filtering(o,f,mode);
            f.calc_ctf = true;   
        end  
    elseif s.calc_ctf               % Default setting
        f = initialize_subtomo_ctf_filtering(o,f,mode);
        f.calc_ctf = true;
    end
end

% Check for exposure filtering in wedgelist
if isfield(o.wedgelist,'exposure') && isfield(o.wedgelist,'pixelsize')  % Check for required information
    
    if isfield(p(idx),'calc_exp')   % Param-file setting overrides
        if p(idx).calc_exp
            f.calc_exp = true;   
        end  
    elseif s.calc_exp               % Default setting
        f.calc_exp = true;
    end
    
end

% Check for score-based weighting
if isfield(p(idx),'score_weight') && strcmp(mode,'avg')
    if (p(idx).score_weight < 1) && (p(idx).score_weight > 0)
        f.calc_sbw = true;
        % Determine weighting parameters
        f = calculate_score_based_weighting_arrays(p,o,idx,f);
    end
end
        

% Calcualte frequency array
if any([f.calc_ctf,f.calc_exp,f.calc_sbw])
    f = generate_subtomo_frequency_array(o,f,mode);
end



% Cosine filter
if sg_check_param(p(idx),'cos_weight')
    if p(idx).cos_weight > 0
        f.calc_cosine = true; 
    end
end

    











