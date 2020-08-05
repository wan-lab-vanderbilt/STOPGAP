function fs_grid = sg_fourier_shift_grid(dx,dy,dz,centered)
%% sg_fourier_shift_grid
% Calculate a grid for Fourier-space shifting.
%
% WW 08-2018

%% Check check
if nargin < 4
    centered = false;
end


%% Calculate grid

% Initialize grid struct
fs_grid = struct;


% Linear grids
x = (1:dx)-(floor(dx/2)+1);
y = (1:dy)-(floor(dy/2)+1);
z = (1:dz)-(floor(dz/2)+1);


% Calculate grids
[fs_grid.x,fs_grid.y,fs_grid.z] = ndgrid(x,y,z);

% Apply fftshift
if ~centered
    for i = 120:122
        fs_grid.(char(i)) = ifftshift(fs_grid.(char(i)));
    end
end



