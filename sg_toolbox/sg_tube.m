function cylinder = sg_tube(dims,inner_rad,outer_rad,height,sigma,center)
%% sg_tube
% Geneate a tube with gaussian tapering. Sigma can be provided as a 3
% element array to define different sigma for inner and outer radius, and 
% height tapering, respectively.
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
if nargin < 6
    center = floor(dims./2)+1;
end
if numel(center) == 1
    center = [center,center,center];
elseif numel(center) ~= 3
    error('ACHTUNG!!! Invalid center dimensions!!!');
end

% Check sigma
if (nargin == 4) || isempty(sigma)
    sigma = [0,0,0];
elseif numel(sigma) == 1
    sigma = [sigma,sigma,sigma];
end


%% Calculate height window

% Z-distance
dist_z = abs((1:dims(3))-center(3));

% Calculate hard window
window_z = double(dist_z <= (height/2));

% Apply taper
if sigma(3)~=0 && ~isempty(sigma)
    
    sigma_idx = dist_z > (height/2);
    window_z(sigma_idx) = exp(-((dist_z(sigma_idx)-(height/2))/sigma(3)).^2);
    window_z(window_z < exp(-2)) = 0;
    
end

% Project to 3D
window_3d = repmat(permute(window_z,[3,1,2]),[dims(1),dims(2),1]);


%% Generate cylinder

% Calculate circle
annulus = sg_annulus(dims(1:2),inner_rad,outer_rad,sigma(1,2),center(1:2));

% Generate cylinder
cylinder = repmat(annulus,[1,1,dims(3)]).*window_3d;

