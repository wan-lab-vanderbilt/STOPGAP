function d_array = sg_distancearray(image,pixelsize)

%% sg_frequencyarray
% A function to take a volume and a pixelsize and generate an array with
% distances from the center of the box. 
%
% WW 12-2015


% Get size of image
[dimx, dimy, dimz] = size(image);

% Euclidean pixel distances
[x,y,z] = ndgrid(-floor(dimx/2):-floor(dimx/2)+dimx-1,-floor(dimy/2):-floor(dimy/2)+dimy-1,-floor(dimz/2):-floor(dimz/2)+dimz-1);

% Calculate distance array
d_array = sqrt((x.^2)+(y.^2)+(z.^2)).*pixelsize;