function cylinder = sg_cylinder(dims,radius,height,sigma,center)
%% sg_cylinder
% Geneate a cylinder with gaussian tapering. Sigma can be provided as a 2
% element array to define different sigma for radius and height tapering,
% respectively.
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

% Check centers
if nargin < 5
    center = floor(dims./2)+1;
end
if numel(center) == 1
    center = [center,center,center];
elseif numel(center) ~= 3
    error('ACHTUNG!!! Invalid center dimensions!!!');
end

% Check sigma
if (nargin == 3) || isempty(sigma)
    sigma = [0,0];
elseif numel(sigma) == 1
    sigma = [sigma,sigma];    
end


%% Calculate height window

% Z-distance
dist_z = abs((1:dims(3))-center(3));

% Calculate hard window
window_z = double(dist_z <= (height/2));

% Apply taper
if sigma(2)~=0 && ~isempty(sigma)
    
    sigma_idx = dist_z > (height/2);
    window_z(sigma_idx) = exp(-((dist_z(sigma_idx)-(height/2))/sigma(2)).^2);
    window_z(window_z < exp(-2)) = 0;
    
end

% Project to 3D
window_3d = repmat(permute(window_z,[3,1,2]),[dims(1),dims(2),1]);


%% Generate cylinder

% Calculate circle
circle = sg_circle(dims(1:2),radius,sigma(1),center(1:2));

% Generate cylinder
cylinder = repmat(circle,[1,1,dims(3)]).*window_3d;

