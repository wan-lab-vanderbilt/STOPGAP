function f = refresh_filters(p,o,f,idx,motl,mode)
%% refresh_filters
% A function for checking and refreshing the filters during a subtomogram
% averaging run. General parameters come from the 'p' and 'o' structs,
% while the iterative parameters come from the 'f' struct. 
%
% The 'mode' input is a switch either for alignment (align) or averaging
% (aver). This affects how the special filters are refreshed.
%
% v1: 11-2017
% v2: 01-2018 - added on-the-fly per-slice wedgemask generation, ctf
%
% WW 01-2018

%% Initail parameters

if strcmp(mode,'align')
    fname = {'ali_reffiltername','ali_particlefiltername'};    
elseif strcmp(mode,'aver')
    fname = {'avg_reffiltername','avg_particlefiltername'};    
else
    error('Achtung!!! Incorrect mode for "refresh_filters"');
end

ftype = {'reffiltertype','particlefiltertype'};
ffilt = {'rfilt','pfilt'};


%% Calculate per-tomogram filters

if f.tomo ~= motl(p(idx).tomorow,1,1)
    
    % Update tomogram number
    f.tomo = motl(p(idx).tomorow,1,1);
    new_tomo = true;
    
    % Regenerate binary wedge mask
    switch f.wedge_type
        case 'wedge'
            
            % Determine tomogram index
            tomo_idx = find(o.wedgelist(1,:)==f.tomo);
            if isempty(tomo_idx)
                error(['ACHTUNG!!! Tomogram number ',num2str(f.tomo),' is NOT in the wedgelist!!!']);
            end
            
            % Calcualte binary mask
            minangle = o.wedgelist(2,tomo_idx);
            maxangle = o.wedgelist(3,tomo_idx);
            f.bin_wedge = av3_wedge(zeros(o.boxsize,o.boxsize,o.boxsize),minangle,maxangle);
            
            % IFFT for align mode
            if strcmp(mode,'align');
                f.bin_wedge = ifftshift(f.bin_wedge);
            end
        
        case 'slice'
            
            % Wedgelist index
            f.wedge_idx = find([o.wedgelist.tomo_num] == motl(p(idx).tomorow,1,1));
            
            % Calcualte binary mask, slice indices, and slice weights
            f = generate_wedgemask_slices(o,f,mode);
                      
    end

    % Set reference and particle filters
    f.rfilt = f.bin_wedge;
    f.pfilt = f.bin_wedge;
      
else
    
    % Do not refresh tomogram dependent filters
    new_tomo = false;
    
    % Set reference and particle filters
    f.rfilt = f.bin_wedge;
    f.pfilt = f.bin_wedge;
    
end

%% Check external filters

% Loop for reference and particle filters
for i = 1:2
    if ~strcmp(p(idx).(fname{i}),'none')

        switch p(idx).(ftype{i})
            case 'tomo'
                if new_tomo                
                    % Read filter
                    name = [p(idx).(fname{i}),'_',num2str(f.tomo),'.em'];
                    filt = read_em(p(idx).rootdir,name);
                    
                    % IFFT for align mode
                    if strcmp(mode,'align')
                        filt = ifftshift(filt);
                    end
                    
                    % Generate new filter
                    f.(ffilt{i}) = f.(ffilt{i}).*filt;
                end
                
                
            case 'subtomo'
                % Read filter
                name = [p(idx).(fname{i}),'_',num2str(motl(4,1,1)),'.em'];
                filt = read_em(p(idx).rootdir,name);
                
                % IFFT for align mode
                if strcmp(mode,'align');
                    filt = ifftshift(filt);
                end
                
                % Generate new filter
                f.(ffilt{i}) = f.(ffilt{i}).*filt;
        end
    end
end                
                

%% Calculate additional reference filters

% Refresh exposure filter
if f.calc_exposure
    
    if new_tomo
        % Generate filter
        f = generate_exposure_filter_slices(o,f);
    end
    
    % Apply filter
    f.rfilt = f.rfilt.*f.exp_filt;    

end

% Generate CTF filter
if strcmp(f.wedge_type,'slice') && f.calc_ctf    
    % Get local defocus values
    defocii = calculate_local_defocii(p,o,f,idx,motl);
%     defocii = [o.wedgelist(f.wedge_idx).defocii];
    
    % Calculate CTF filter
    f = generate_ctf_slices(o,f,defocii);    
    
    % Apply CTF filter
    f.rfilt = f.rfilt.*f.ctf_filt;    

end

  

