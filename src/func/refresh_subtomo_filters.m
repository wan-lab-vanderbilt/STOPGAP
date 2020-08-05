function f = refresh_subtomo_filters(p,o,s,f,idx,motl,step)
%% refresh_subtomo_filters
% A function for checking and refreshing the filters during a subtomogram
% averaging run. General parameters come from the 'p' and 'o' structs,
% while the iterative parameters come from the 'f' struct. 
%
% The 'mode' input is a switch either for alignment (ali) or averaging
% (avg). This affects how the special filters are refreshed.
%
% v1: 11-2017
% v2: 01-2018 - added on-the-fly per-slice wedgemask generation, ctf
%
% WW 01-2018

%% Initail parameters

% Filter names
ftype = {'reffiltertype','particlefiltertype'};
ffilt = {'rfilt','pfilt'};


% Check mode
switch step
    case 'ali'
        fname = {'ali_reffiltername','ali_particlefiltername'};    
        shift = true;
    case 'avg'
        fname = {'avg_reffiltername','avg_particlefiltername'};    
        shift = false;
    otherwise
        error('Achtung!!! Incorrect mode for "refresh_filters"');
end



%% Check for new tomogram, subtomogram, and class

% Check for new class for score-based weighting
if f.calc_sbw
    mode = strsplit(p(idx).subtomo_mode,'_');

    % Check for new class
    switch mode{2}
        case 'singleref'
            class = 1;
        otherwise
            class = motl.class(1);
    end
    if f.class ~= class
        f.class = class;
        new_class = true;
    else
        new_class = false;
    end
end


% Check for new filter
if f.tomo ~= motl.tomo_num(1)
    
    % Update tomogram number
    f.tomo = motl.tomo_num(1);
    new_tomo = true;
        
    % Wedgelist index
    f.wedge_idx = find([o.wedgelist.tomo_num] == motl.tomo_num(1));

    % Calcualte binary mask, slice indices, and slice weights
    switch step
        case 'ali'
            [f.bin_wedge,f.wedge_weight,f.slice_idx] = generate_wedgemask_slices(o.boxsize,o.wedgelist(f.wedge_idx).tilt_angle,o.bpf,shift);
        case 'avg'
            if o.avg_ss > 1
                boxsize = o.ss_boxsize;
            else
                boxsize = o.boxsize;
            end
            bpf = sg_sphere(boxsize,floor(min(boxsize/2))-1);
            [f.bin_wedge,f.wedge_weight,f.slice_idx] = generate_wedgemask_slices(boxsize,o.wedgelist(f.wedge_idx).tilt_angle,bpf,shift);
    end
   
    % Set reference and particle filters
    f.rfilt = f.bin_wedge;
    f.pfilt = f.bin_wedge;
      
else
    
    % Do not refresh tomogram dependent filters
    new_tomo = false;       
    
end

% Check for new subtomogram
if f.subtomo ~= motl.subtomo_num(1)    
    
    % Update subtomogram
    f.subtomo = motl.subtomo_num(1);
    
    % Reinitalize filters
    f.rfilt = f.bin_wedge;
    f.pfilt = f.bin_wedge;
    
else
    
    % Return with old filters
    return
end



%% Check external filters

% Loop for reference and particle filters
for i = 1:numel(fname)
    if sg_check_param(p(idx),fname{i})

        switch p(idx).(ftype{i})
            case 'tomo'
                
                % Check for new tomogram
                if new_tomo                
                    % Read filter
                    name = [p(idx).(fname{i}),'_',num2str(f.tomo),s.vol_ext];
                    f.(fname{i}) = s.read_vol(p(idx).rootdir,name); 
                    % IFFT for align mode
                    if strcmp(step,'ali') && (i < 3)
                        f.(fname{i}) = ifftshift(f.(fname{i}));
                    end
                end   
   
            case 'subtomo'   % At this point, it's always a new subtomogram
                
                % Read filter
                name = [p(idx).(fname{i}),'_',num2str(f.subtomo),s.vol_ext];
                f.(fname{i}) = s.read_vol(p(idx).rootdir,name);
                % IFFT for align mode
                if strcmp(step,'ali') && (i < 3)
                    f.(fname{i}) = ifftshift(f.(fname{i}));
                end
        end
                
        % Apply external filter
        f.(ffilt{i}) = f.(ffilt{i}).*f.(fname{i});
                
                
    end
end                
                

%% Calculate additional reference filters

% Refresh exposure filter
if f.calc_exp
    
    if new_tomo
        % Generate filter
        f = generate_exposure_filter_slices(o,f,step);
    end
    
    % Apply filter
    f.rfilt = f.rfilt.*f.exp_filt;    

end

% Generate CTF filter
if f.calc_ctf        
    
    % Calculate filter
    f = calculate_subtomo_ctf_filter(p,o,s,f,idx,motl,new_tomo,step);
    
    % Apply CTF filter
    f.rfilt = f.rfilt.*f.ctf_filt;    

end
   

% Refresh Cosine filter
if f.calc_cosine
    
    if new_tomo
        % Generate filter
         f = generate_cosine_filter(p,o,idx,f,step);
    end
    
    % Apply filter
    f.rfilt = f.rfilt.*f.cos_filt;    
    f.pfilt = f.pfilt.*f.cos_filt;
        
end 


% Refresh score-based weighting filter
if f.calc_sbw
    
    % Refresh filter
    if new_tomo  || new_class
        f = score_based_weighting(p,idx,o,f,motl,'init');
    end
    
    % Calculate filter for subtomogram
    f = score_based_weighting(p,idx,o,f,motl,'calc');
    
    % Apply filter
    f.rfilt = f.rfilt.*f.sbw_filt;    
    f.pfilt = f.pfilt.*f.sbw_filt; 
    
    
end

    

