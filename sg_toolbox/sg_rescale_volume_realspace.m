function r_vol = sg_rescale_volume_realspace(vol,new_dims,method)
%% sg_rescale_volume_realspace
% Rescale a new volume using real-space interpolation. 
%
% WW 08-2018

%% Check check

% Check dimensions
if numel(new_dims) == 1
    new_dims = ones(1,3).*new_dims;
end

% Check method
if nargin == 2
    method = 'linear';
elseif nargin ~= 3
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end

%% Initial grid

% Size of volume
dims = size(vol);

% Linear grid
lin_grid = cell(3,1);
for i = 1:3
    s = floor(-dims(i)/2);
    e = s + dims(i) -1;
    lin_grid{i} = (s:e)./floor(dims(i)/2);
end

% 3D grids
[x,y,z] = ndgrid(lin_grid{1}, lin_grid{2}, lin_grid{3});



%% Rescale grid

% Linear grid
lin_grid = cell(3,1);
for i = 1:3
    s = floor(-new_dims(i)/2);
    e = s + new_dims(i) -1;
    lin_grid{i} = (s:e)./floor(new_dims(i)/2);
end

% 3D grids
[rx,ry,rz] = ndgrid(lin_grid{1}, lin_grid{2}, lin_grid{3});



%% Rescale volume

% Generate gridded interpolant
F = griddedInterpolant(x,y,z,vol,method,'none');

% Interpolate grid
r_vol = F(rx,ry,rz);
nan_idx = isnan(r_vol);
r_vol(nan_idx) = 0;


