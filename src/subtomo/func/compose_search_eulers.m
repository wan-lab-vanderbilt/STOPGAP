function [phi,psi,the] = compose_search_eulers(p,o,idx,motl,entry)
%% compose_search_eulers
% Take an input parameters and starting angles from a motivelist entry,
% and compose search angles.
%
% Angles are returend as three cell arrays
%
% WW 06-2019

%% Initialize

% Initialize arrays
phi = cell(o.n_ang,1);
psi = cell(o.n_ang,1);
the = cell(o.n_ang,1);


%% Compose search angle

% Check check
if sg_check_param(p(idx),'search_type')
    search_type = p(idx).search_type;
else
    search_type = 'cone';
end

% Generate angles
switch search_type
    
    case 'euler'
        
        % Generate starting quaternion
        q_old = sg_euler2quaternion(motl.phi(entry),motl.psi(entry),motl.the(entry));
        
        % Compose angles
        for i = 1:o.n_ang
            q_search = sg_quaternion_multiply(q_old,o.q_ang{i});  % Compose search quaternion
            [phi{i},psi{i},the{i}] = sg_quaternion2euler(q_search);   % Convert quaternion to Euler
        end
        
    case 'cone'
        
        % Compose angles
        for i = 1:o.n_ang
            
            % Rotate vector
            r = tom_pointrotate([0,0,1],0,o.anglist(2,i),o.anglist(3,i));
            r = tom_pointrotate(r,0,motl.psi(entry),motl.the(entry));    
            
            phi{i} = motl.phi(entry) + o.anglist(1,i);
            psi{i} = atan2d(r(2),r(1))+90;
            the{i} = atan2d( sqrt( (r(1)^2) + (r(2)^2) ) , r(3) );
        end
end



