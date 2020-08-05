function o = sg_ali_cone_angles(o,angincr,angiter,phi_angincr,phi_angiter)


% Calculate cone angles
cone_angles = calculate_cone_angles(angincr, angiter, 'coarse');
n_cones = size(cone_angles,2);

% Calculate phi angles
phi_range = phi_angincr*phi_angiter;
phi_array = circshift(-phi_range:phi_angincr:phi_range,[1,-phi_angiter]); % Places no-rotation at first position
if isempty(phi_array)
    phi_array = 0;
end
n_phi = numel(phi_array);

% Generate triples
n_angles = n_cones*n_phi;
o.anglist = cat(1,reshape(repmat(phi_array,[n_cones,1]),[1,n_angles]),repmat(cone_angles,[1,n_phi]));
o.n_ang = size(o.anglist,2);