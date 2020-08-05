function rot_vol = sg_rotate_cubic(vol,eulers,center)
%% sg_rotate_cubic
% A rotation function for cubic volumes using tricubic interpolation. A bit
% slow as it uses built in matlab functions. 
%
% This is ore accurate than the linear interpolation intom_rotate but for
% typical subtomogram averaging volume sizes is ~1.5-2.5x slower.
%
% WW 12-2016


%% Check check

% Size of volume
dims = size(vol);

% Check center
if (nargin == 2) || isempty(center)
    center = floor(dims./2)+1;
elseif nargin ~= 3
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end

% Check number of eulers
if numel(eulers)~=3
    error('ACHTUNG!!! Incorrect number of input eulers!!!');
end


%% Initialize grids and interpolant

% Parse eulers
phi = eulers(1);
psi = eulers(2);
the = eulers(3);


% Linear grids
lin_x = (1:dims(1))-center(1);
lin_y = (1:dims(2))-center(2);
lin_z = (1:dims(3))-center(3);

% 3D grids
[gx,gy,gz] = ndgrid(lin_x, lin_y, lin_z);

% Initialize cubic
F = griddedInterpolant(gx,gy,gz,vol,'cubic','none');


%% Generate rotation grid

% Generate rotation matrix
rot_mat = sg_euler2matrix(-psi,-phi,-the);

% Calculate rotated gridpoints
rot_grid=rot_mat*[gx(:),gy(:),gz(:)]';

% Perform interpolation
rot_vol = F(rot_grid');
rot_vol(isnan(rot_vol)) = 0;
rot_vol = reshape(rot_vol,dims);

