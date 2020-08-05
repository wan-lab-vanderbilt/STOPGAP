function [o,v,ali] = flcf_subtomo_scoring_function(p,o,s,idx,v,f,score_mode,ali)
%% flcf_subtomo_scoring_function
% A functon for initializing, preparing, and performing the Roseman
% fast local correlation function (FLCF).
%
% WW 06-2019

%% Calculate FLCF
mode = strsplit(p(idx).subtomo_mode,'_');

switch score_mode
    
    % FLCF has no initaliziation step
    case 'init'
        return
        
    % Prepare subtomogram for calculation
    case 'prep'
        
        % Fourier transform particle        
        fsubtomo = fftn(v.subtomo);
                
        % Check Fourier cropping
        if o.fcrop
            fsubtomo = fcrop_fftshifted_vol(fsubtomo,o.f_idx);
        end
        
        % Apply filter
        fsubtomo = fsubtomo.*f.pfilt.*o.bpf;
        % Force 0-frequency peak to zero
        fsubtomo(1,1,1) = 0;     


        % Store complex conjugate
        v.conjSubtomo = conj(fsubtomo); 
        
        % Store complex conjugate of square
        v.conjSubtomo2 = conj(fftn(ifftn(fsubtomo).^2));
    
    
    % Apply alignment parameters to reference and score
    case 'score'

        % Check for stochastic search
        if any(strcmp(p(idx).search_mode,{'shc','sga'}))
            stochastic = true;
        else
            stochastic = false;
        end
        
        % Check for simulated annealing
        sim_anneal = false;
        if sg_check_param(p(idx),'temperature')
            if p(idx).temperature > 0
                stochastic = true;
                sim_anneal = true;
            end
        end
        
        % Loop across each entry
        ali_size = size(ali);
        for j = 1:ali_size(2)
            
            % Loop across all search angles
            for i = 1:ali_size(1)
            
                %%%%% Copy volumes %%%%%
                switch mode{2}
                    case 'singleref'
                        class_idx = 1;
                    otherwise
                        class_idx = find(o.classes == ali(i,j).class);    % Parse reference
                end
                ref = o.ref(class_idx).(ali(i,j).halfset);        % Copy reference
                mask = o.mask{class_idx};                       % Copy mask
        
                
        
                %%%%% Prepare Reference %%%%%

                % Rotate the reference
                ref = sg_rotate_vol(ref,[ali(i,j).phi,ali(i,j).psi,ali(i,j).the],[],o.rot_mode);

                % Rotate mask
                mask = sg_rotate_vol(mask,[ali(i,j).phi,ali(i,j).psi,ali(i,j).the],[],o.rot_mode);

                % Apply filters
                ref = real(ifftn(fftn(ref).*f.rfilt.*o.bpf));    

                % Inverse transform particle and normalize under mask
                ref = normalize_under_mask(ref,mask);  
        
            
        
                %%%%% Score %%%%%

                % Calculate FLCF
                scoring_map = calculate_flcf(ref,mask,v.conjSubtomo,v.conjSubtomo2);
                if o.fcrop
                    scoring_map = fourier_uncrop_volume(scoring_map,o.f_idx);
                end
        
        
        
                %%%%% Find Peak %%%%%

                % Rotate CC mask
                rccmask = sg_rotate_vol(o.ccmask,[ali(i,j).phi,ali(i,j).psi,ali(i,j).the],[],o.rot_mode);

                % Find ccc peak
                [pos, score] = find_subpixel_peak(scoring_map, rccmask);
                if o.fcrop
                    shift = pos-o.full_cen;  % Shift from center of box
                else
                    shift = pos-o.cen;  % Shift from center of box
                end
        
                % Store alignment parameters
                ali(i,j).score = score;
                ali(i,j).new_shift = shift;

                % Check stochastic search exit condition
                if stochastic
                    if i > 1
                        
                        % Basic stochastic hill climb
                        if ali(i,j).score > ali(1,j).score                            
                            break
                            
                        % Simulated annealing
                        elseif sim_anneal
                            
                            % Calculate random number
                            rp   = rand(1);
                            
                            % Check against random probability
                            if (p(idx).temperature/100) > rp
                                
                                % Accept downhill move
                                ali_idx = (1:ali_size(1))~=i;                           % Find all other entries
                                score_cell = num2cell(ones(ali_size(1)-1,1).*-2);
                                [ali(ali_idx,j).score] = score_cell{:};             % Set all other scores to -2
                                break
                                
                            end
                                
                            % Continue alignment
                        end
                    end
                end
                
            end     % End angle loop
        end         % End entry loop

        
           
    otherwise
        error([s.nn,'ACHTUNG!!! Invalid mode!!!']);        
                
end
