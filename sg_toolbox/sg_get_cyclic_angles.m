function angles = sg_get_cyclic_angles(n_fold)
%% sg_get_cyclic_angles
% Generate Euler angles for cyclic symmetry.

% Generate phi angles
phi = linspace(0,360,(n_fold+1));
phi = phi(1:end-1);

% Generate cell array with triplets
angles = cell(n_fold,1);
for i = 1:n_fold
    angles{i} = [phi(i),0,0];
end

end