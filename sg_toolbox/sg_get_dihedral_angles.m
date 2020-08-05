function angles = sg_get_dihedral_angles(n_fold)
%% sg_get_dihedral_angles
% Generate Euler angles for diheral symmetry.

% Generate phi angles
phi = linspace(0,360,(n_fold+1));
phi = phi(1:end-1);

% Generate cell array with triplets
angles = cell(n_fold*2,1);
p = 1;
for i = 1:2:n_fold*2
    angles{i} = [phi(p),0,0];
    angles{i+1} = [phi(p),0,180];
    p = p+1;
end

end