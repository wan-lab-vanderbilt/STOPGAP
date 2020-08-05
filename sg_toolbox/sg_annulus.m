function annulus = sg_annulus(dims,inner_rad,outer_rad,sigma,center)
%% sg_annulus
% A function to generate an annulus; i.e. a holey circle, with Gaussian 
% tapering and arbitrary center. Two sigma values can be given for
% different inner and outer sigma values, respectively.
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
if nargin < 5
    center = floor(dims./2)+1;
end

% Check sigma
if (nargin == 3) || isempty(sigma)
    sigma = [0,0];
elseif numel(sigma) == 1
    sigma = [sigma,sigma];
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
annulus = double((dist >= inner_rad) & (dist <= outer_rad));


%% Calculate sigma

if any(sigma~=0) && ~isempty(sigma)
    
    % Inner taper
    sigma1_idx = dist < inner_rad;
    annulus(sigma1_idx) = exp(-((inner_rad-dist(sigma1_idx))/sigma(1)).^2);
    
    % Outer taper
    sigma2_idx = dist > outer_rad;
    annulus(sigma2_idx) = exp(-((dist(sigma2_idx)-outer_rad)/sigma(2)).^2);
    
    
    
    % Threshold taper    
    annulus(annulus < exp(-2)) = 0;
end

