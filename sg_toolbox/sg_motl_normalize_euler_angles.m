function motl = sg_motl_normalize_euler_angles(motl)
%% sg_motl_normalize_euler_angles
% A function to take a motivelist and normalize the Euler angles. Phi and
% psi angles should be between +/- 180 while theta should be between 0 and 
% 180. 
%
% WW 08-2023


%% Normalize angles

% Check motivelist type
read_type = sg_motl_check_read_type(motl);

% Normalize
switch read_type
    
    case 1
        
        n_motls = numel(motl);
        for i = 1:n_motls
            [motl(i).phi,motl(i).psi,motl(i).the] = sg_normalize_eulers(motl(i).phi,motl(i).psi,motl(i).the);
        end
        
        
    case 2
        n_motls = numel(motl.phi);
        for i = 1:n_motls
            [motl.phi(i),motl.psi(i),motl.the(i)] = sg_normalize_eulers(motl.phi(i),motl.psi(i),motl.the(i));
        end
        
end




