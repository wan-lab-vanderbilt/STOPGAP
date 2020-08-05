function sphere = sg_sphere(dims,radius,sigma,center)
%% sg_sphere
% Calcualte a sphere with given radius and Gaussian taper. 
%
% WW 09-2018

%% Check check

% Check dimensions
n_dims = numel(dims);
if n_dims == 1
    dims = [dims,dims,dims];
elseif n_dims ~= 3
    error('ACHTUNG!!! Invalid number of dimensions!!!');
end

% Calculate centers
if nargin < 4
    center = floor(dims./2)+1;
end

% Check sigma
if (nargin == 2) || isempty(sigma)
    sigma = 0;
end


%% Calculate sphere

% Linear grids
lin_x = (1:dims(1))-center(1);
lin_y = (1:dims(2))-center(2);
lin_z = (1:dims(3))-center(3);

% 3D grids
[x,y,z] = ndgrid(lin_x, lin_y, lin_z);

% Calculate distance array
dist = sqrt((x.^2)+(y.^2)+(z.^2));

% Calculate circle
sphere = double(dist <= radius);


%% Calculate sigma

if sigma ~= 0
    
    sigma_idx = dist > radius;
    sphere(sigma_idx) = exp(-((dist(sigma_idx)-radius)/sigma).^2);
    sphere(sphere < exp(-2)) = 0;
end

