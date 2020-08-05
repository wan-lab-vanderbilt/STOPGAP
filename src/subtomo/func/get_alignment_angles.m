function o = get_alignment_angles(p,o,s,idx,mode)
%% Get angles
% A function to calculate cone search angles. Parameters are read from the
% p struct for given idx and stored in the o struct. 
% 
% Mode can be 'init', which forces generation of a filter, while 'refresh'
% generates a new filter if the bandpass filter settings change between idx
% and idx-1.
%
% WW 11-2017


%% Parse search type
if sg_check_param(p(idx),'search_type')
    search_type = p(idx).search_type;
else    
    search_type = 'cone';
end

%% Check for refresh

switch mode
    case 'init'
        gen_ang = true;
    case 'refresh'
        
        if idx == 1 % First index
            
            gen_ang = true;            
            
        elseif sg_check_param(p(idx),'search_type')
            
             % Change in search_type
            if ~strcmp(p(idx).search_type,p(idx-1).search_type)
                gen_ang = true;
            end
            
        else
            
            switch search_type
                
                case 'euler'
                    
                    % Check for changes
                    a = (p(idx).euler_1_incr ~= p(idx-1).euler_1_incr);
                    b = (p(idx).euler_1_iter ~= p(idx-1).euler_1_iter);
                    c = (p(idx).euler_2_incr ~= p(idx-1).euler_2_incr);
                    d = (p(idx).euler_2_iter ~= p(idx-1).euler_2_iter);
                    e = (p(idx).euler_3_incr ~= p(idx-1).euler_3_incr);
                    f = (p(idx).euler_3_iter ~= p(idx-1).euler_3_iter);
                    
                    if any([a,b,c,d,e,f])
                        gen_ang = true;
                    else
                        gen_ang = false;
                    end
                    
                    
                case 'cone'
                    
                    % Check for changes
                    a = (p(idx).angincr ~= p(idx-1).angincr);
                    b = (p(idx).angiter ~= p(idx-1).angiter);
                    c = (p(idx).phi_angincr ~= p(idx-1).phi_angincr);
                    d = (p(idx).phi_angiter ~= p(idx-1).phi_angiter);        

                    if any([a,b,c,d])
                        gen_ang = true;
                    else
                        gen_ang = false;
                    end
            end
        end
end

%% Generate angle list
if gen_ang
    
    
    switch search_type
        
        case 'euler'
            disp([s.nn,'Calculating Euler search angles...']);
            
            % Calculate Euler angles
            o = calculate_arbitrary_eulers(p,o,idx);
            
        case 'cone'
            disp([s.nn,'Calculating cone-search angles...']);
            
            % Calculate cone angles
            o = calculate_cone_angle_list(p,o,idx);
            
    end

end

end


