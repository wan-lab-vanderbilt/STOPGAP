function o = generate_bpf(p,o,idx,mode)
%% generate_bpf
% A function to generate a bandpass filter. Parameters are taken from the
% 'p' struct, and filter is stored in the 'o' struct. 
% 
% Mode can be 'init', which forces generation of a filter, while 'refresh'
% generates a new filter if the bandpass filter settings change between idx
% and idx-1.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to allow for calculation of bandpass filters from
% real-space resolutions
%
% WW 01-2018


%% Check for change in filter
switch mode
    case 'init'
        gen_bpf = true;
    case 'refresh'
        
        if idx == 1
            
            gen_bpf = true;
            
        elseif ~strcmp(p(idx).bp_input_type,p(idx-1).bp_input_type)
            
            gen_bpf = true;
            
        else
            
            % Check for changes
            a = (p(idx).lp_rad ~= p(idx-1).lp_rad);
            b = (p(idx).lp_sigma ~= p(idx-1).lp_sigma);
            c = (p(idx).hp_rad ~= p(idx-1).hp_rad);
            d = (p(idx).hp_sigma ~= p(idx-1).hp_sigma);

            if any([a,b,c,d])
                gen_bpf = true;
            else
                gen_bpf=false;
            end
        end
end

%% Generate new filter

if gen_bpf
    
    % Check radii
    if strcmp(p(idx).bp_input_type,'real')
        lp_rad = round((o.boxsize*p(idx).pixelsize)/p(idx).lp_rad);
        hp_rad = round((o.boxsize*p(idx).pixelsize)/p(idx).hp_rad);
    else
        lp_rad = p(idx).lp_rad;
        hp_rad = p(idx).hp_rad;
    end
    
    % Check sigmas    
    if ~isfield(p(idx),'lp_sigma') || (p(idx).lp_sigma==0)
        lp_sigma = 3;
    else
        if strcmp(p(idx).bp_input_type,'real')
            lp_sigma = round((o.boxsize*p(idx).pixelsize)/p(idx).lp_sigma)-lp_rad;
        else
            lp_sigma = p(idx).lp_sigma;
        end
    end
    if ~isfield(p(idx),'hp_sigma') || (p(idx).hp_sigma==0)
        hp_sigma = 2;
    else
        if strcmp(p(idx).bp_input_type,'real')
            hp_sigma = round((o.boxsize*p(idx).pixelsize)/p(idx).hp_sigma)-hp_rad;
        else
            hp_sigma = p(idx).hp_sigma;
        end
    end
    
    % Generate filter
    dims = [o.boxsize,o.boxsize,o.boxsize];
    lowpass = tom_sphere(dims,lp_rad,lp_sigma);
    hipass = tom_sphere(dims,hp_rad,hp_sigma);
    o.bandpass = ifftshift(lowpass-hipass); % Bandpass filter
    
    
end        
