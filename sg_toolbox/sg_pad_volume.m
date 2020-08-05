function padvol = sg_pad_volume(volume,new_size)
%% sg_pad_volume
% A function to take an input 3D-volume and pad it by placing it into the
% center of a box of given dimensions. If one input dimension is given, the
% padded volume is a cube, otherwise the padded dimensions are equivalent
% to the three input dimensions. 
%
% WW 11-2018

%% Create padding box

% Parse padded dimensions
if numel(new_size) == 1
    padsize = ones(1,3)*new_size;
elseif numel(new_size) == 3
    padsize = new_size;
else
    error('ACHTUNG!!! new_size must be either 1 or 3 elements!!!');
end

% Initialize padded box
padvol = zeros(padsize,'like',volume);

%% Parse padded indices

% Size of volume
volsize = size(volume);

% Starting indices
x_start = ceil((padsize(1)-volsize(1))/2)+1;
y_start = ceil((padsize(2)-volsize(2))/2)+1;
z_start = ceil((padsize(3)-volsize(3))/2)+1;

% Ending indices
x_end = x_start+volsize(1)-1;
y_end = y_start+volsize(2)-1;
z_end = z_start+volsize(3)-1;

%% Return padded volume

% Pad volume
padvol(x_start:x_end,y_start:y_end,z_start:z_end) = volume;




