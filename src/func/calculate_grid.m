function grid = calculate_grid(boxsize,mode)
%% calculate_grid
% A function for calculating a grid of points wiht ndgrid. 
%
% Returned grid can be normal or ifftshifted.
%
% WW 02-2018

%% Check check

if nargin == 1
    mode = 'avg';
elseif nargin ==2
    if ~any(strcmp(mode,{'ali','avg'}))
        error('ACHTUNG!!! Invalid mode!!!');
    end
else 
    error('ACHTUNG!! Invalid number of inputs!!!');
end

%% Calculate grid

% Initialize grid struct
grid = struct;

% Grid bounds
g1 = -floor(boxsize/2);
g2 = g1 + (boxsize-1);

% Calculate grids
[grid.x,grid.y,grid.z] = ndgrid(g1:g2,g1:g2,g1:g2);

% IFFTSHIFT
if strcmp(mode,'align')
    grid.x = ifftshift(grid.x);
    grid.y = ifftshift(grid.y);
    grid.z = ifftshift(grid.z);
end




