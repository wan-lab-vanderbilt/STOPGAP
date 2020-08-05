function circle = sg_circle(dims,radius,sigma,center)
%% sg_circle
% A function to generate a circle, with Gaussian tapering and arbitrary
% center.
%
% WW 09-2018

%% Check check

% Check dimensions
n_dims = numel(dims);
if n_dims == 1
    dims = [dims,dims];
elseif n_dims ~= 2
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


%% Calculate circle

% Linear grids
lin_x = (1:dims(1))-center(1);
lin_y = (1:dims(2))-center(2);

% 2D grids
[x,y] = ndgrid(lin_x, lin_y);

% Calculate distance array
dist = sqrt((x.^2)+(y.^2));

% Calculate circle
circle = double(dist <= radius);


%% Calculate sigma

if (sigma~=0) && ~isempty(sigma)
    
    sigma_idx = dist > radius;
    circle(sigma_idx) = exp(-((dist(sigma_idx)-radius)/sigma).^2);
    circle(circle < exp(-2)) = 0;
end

