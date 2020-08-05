function r_img = sg_rescale_image_realspace(img,new_dims,method)
%% sg_rescale_image_realspace
% Rescale a new image using real-space interpolation. 
%
% WW 08-2018

%% Check check

% Check dimensions
if numel(new_dims) == 1
    new_dims = ones(1,2).*new_dims;
end

% Check method
if nargin == 2
    method = 'linear';
elseif nargin ~= 3
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end

% Size of volume
dims = size(img);
if all(dims(:) == new_dims(:))
    r_img = img;
    return;
end


%% Initial grid

% Linear grid
lin_grid = cell(2,1);
for i = 1:2
    s = floor(-dims(i)/2);
    e = s + dims(i) -1;
    lin_grid{i} = (s:e)./floor(dims(i)/2);
end

% 2D grids
[x,y] = ndgrid(lin_grid{1}, lin_grid{2});



%% Rescale grid

% Linear grid
lin_grid = cell(2,1);
for i = 1:2
    s = floor(-new_dims(i)/2);
    e = s + new_dims(i) -1;
    lin_grid{i} = (s:e)./floor(new_dims(i)/2);
end

% 2D grids
[rx,ry] = ndgrid(lin_grid{1}, lin_grid{2});



%% Rescale volume

% Generate gridded interpolant
F = griddedInterpolant(x,y,img,method,'none');

% Interpolate grid
r_img = F(rx,ry);
nan_idx = isnan(r_img);
r_img(nan_idx) = 0;


