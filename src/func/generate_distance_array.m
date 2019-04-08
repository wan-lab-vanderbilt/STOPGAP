function d_array = generate_distance_array(dims,pixelsize,mode)

%% generate_distance_array
% A function to calculate the distance from the center of an 1 to 3
% dimensional array. 
%
% WW 02-2018

%% Check check

% Default pixelsize
if nargin < 2
    pixelsize = 1;
end
if nargin < 3
    mode = 'aver';
end


% Check dimensions
switch numel(dims)
    case 1
       dimx = dims;
       dimy = 1;
       dimz = 1;
    case 2
       dimx = dims(1);
       dimy = dims(2);
       dimz = 1;
    case 3
       dimx = dims(1);
       dimy = dims(2);
       dimz = dims(3);
end

% Check mode
if ~any(strcmp(mode,{'align','aver'}))
    error('ACHTUNG!!! Only supported modes are "align" or "aver"');
end

%% Calculate distance array


% Euclidean pixel distances
[x,y,z] = ndgrid(-floor(dimx/2):-floor(dimx/2)+dimx-1,-floor(dimy/2):-floor(dimy/2)+dimy-1,-floor(dimz/2):-floor(dimz/2)+dimz-1);

% Calculate distance array
d_array = sqrt((x.^2)+(y.^2)+(z.^2)).*pixelsize;

% Shift based on mode
if strcmp(mode,'align')
    d_array = ifftshift(d_array);
end


