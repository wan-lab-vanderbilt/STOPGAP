function [o,v,ali] = pearson_subtomo_scoring_function(p,o,s,idx,v,f,mode,ali)
%% pearson_subtomo_scoring_function
% A function for intializing, preparing, and refining subtomogram alignment
% using a real-space Pearson correlation function. In this function, the
% shifts are directly refined using a maximization algorithm. 
%
% The proceedure for this is to rotate the mask and reference, and apply
% shifts to the subtomogram. Scoring then performed on the masked-in voxels
% in the rotated reference frame.
%
% WW 06-2019

%% Calculate function

switch mode
    
    case 'init'        
        
        % Pre-calculate grid
        v.grid = calculate_grid(o.boxsize,'ali');

        
        
    case 'prep'
        
                
        % Non-zero Fourier indices
        v.f_idx = (o.bpf.*f.bin_wedge)>0;
        
        % Transform subtomo
        v.subtomo = fftn(v.subtomo);
        if o.fcrop
            v.subtomo = fcrop_fftshifted_vol(v.subtomo,o.f_idx);
        end
        
        % Filter subtomo
        v.subtomo = v.subtomo.*f.pfilt.*o.bpf;
        

        % Store gridpoints
        v.x = v.grid.x(v.f_idx);
        v.y = v.grid.y(v.f_idx);
        v.z = v.grid.z(v.f_idx);        
        
        
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

                class_idx = find(o.classes == ali(i,j).class);    % Parse reference
                ref = o.ref(class_idx).(ali(i,j).halfset);        % Copy reference
                mask = o.mask{class_idx};                       % Copy mask
                
                                                
                %%%%% Prepare Reference %%%%%
                
                % Rotate the reference
                ref = sg_rotate_vol(ref,[ali(i,j).phi,ali(i,j).psi,ali(i,j).the],[],o.rot_mode);

                % Rotate mask
                mask = sg_rotate_vol(mask,[ali(i,j).phi,ali(i,j).psi,ali(i,j).the],[],o.rot_mode);

                % Apply filters
%                 ref = real(ifftn(fftn(ref).*f.rfilt.*o.bpf)); 
                ref = (fftn(ref).*f.rfilt.*o.bpf); 
                if o.fcrop
                    ref = uncrop_fftshifted_vol(ref,o.f_idx);
                    mask = fourier_uncrop_volume(mask,o.f_idx);
                end
                ref = real(ifftn(ref));
                                
        
                % Get mask info
                m_idx = mask > 0;
                m_val = mask(m_idx);
                clear mask

                % Apply mask to reference data
                ref = ref(m_idx).*m_val;
                ref = (ref - mean(ref))./std(ref);  % Normalize
        
        
                %%%%% Score %%%%%
                
                % Parse old shift
                old_shift = -ali(i,j).old_shift;
%                 if o.fcrop
%                     old_shift = -(ali(i,j).old_shift.*(o.boxsize./o.full_boxsize));
%                 else
%                     old_shift = -ali(i,j).old_shift;
%                 end
        
                % Minimze phase residual
                pearson_fun = @(shift) calculate_pearson_align(o,v,ref,m_idx,m_val,shift);                  
                [shift,dcc] = fminsearch(pearson_fun,old_shift);
        
                % Rescale new shifts
%                 if o.fcrop
%                     shift = shift.*(o.full_boxsize./o.boxsize);
%                 end

                % Store parameters
                ali(i,j).score = 1-dcc;
                ali(i,j).new_shift = -shift;

                
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
                                idx = (1:ali_size(1))~=i;                           % Find all other entries
                                score_cell = num2cell(ones(ali_size(1)-1,1).*-2);
                                [ali(idx,j).score] = score_cell{:};             % Set all other scores to -2
                                break
                                
                            end
                                
                            % Continue alignment
                        end
                    end
                end    % End stochastic check
                
                
            end     % End angle loop
        end         % End entry loop
        
        
    otherwise
        error([s.nn,'ACHTUNG!!! Invalid mode!!!']);

        
end

end








