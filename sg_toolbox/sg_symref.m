function symref = sg_symref(ref,n_fold)
%% sg_symref
% Apply n_fold symmetry to input reference. Symmetry is define as rotation
% about the Z-axis.
%
% WW 11-2018

%% Initialize


% Size of volume
dims = size(ref);

% Center of volume
center = floor(dims./2)+1;

% Rotation angles
angles = linspace(0,360,n_fold+1);
angles = angles(1:end-1);
n_angles = numel(angles);

% Intiialize output reference
symref = zeros(dims,'like',ref);

% Reweighting array
weights = zeros(dims,'like',ref);


%% Initialize grids and interpolant

% Linear grids
lin_x = (1:dims(1))-center(1);
lin_y = (1:dims(2))-center(2);
lin_z = (1:dims(3))-center(3);

% 3D grids
[gx,gy,gz] = ndgrid(lin_x, lin_y, lin_z);

% Initialize cubic
F = griddedInterpolant(gx,gy,gz,ref,'cubic','none');


%% Generate symmetry

 % Rotate and sum
for i = 1:n_angles
    
    % Generate rotation matrix
    rot_mat = sg_euler2matrix(0,angles(i),0);

    % Calculate rotated gridpoints
    rot_grid=rot_mat*[gx(:),gy(:),gz(:)]';

    % Perform interpolation
    rot_vol = F(rot_grid');
    idx = ~isnan(rot_vol);
    
    % Store in arrays
    symref(idx) = symref(idx) + rot_vol(idx);
    weights(idx) = weights(idx) + 1;

end

% Return average
idx = weights > 0;
symref(idx) = symref(idx)./weights(idx);



