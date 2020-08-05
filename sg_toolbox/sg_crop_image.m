function crop_vol = sg_crop_image(img,crop_size,center)
%% sg_crop_image
% Crop an image to 'crop_size' around 'center'. If no center is given,
% the center of the box is used. 
%
% WW 01-2019


%% Check check

% Check for box center
dims = size(img);
if nargin == 2
    center = floor(dims./2)+1;
end

% Check input vectors
if numel(crop_size) == 1
    crop_size = ones(1,2).*crop_size;
elseif numel(crop_size) ~=2
    error('ACHTUNG!!! Invalid number of inputs for "crop_size"!!!');
end
if numel(center) == 1
    center = ones(1,2).*center;
elseif numel(center) ~=2
    error('ACHTUNG!!! Invalid number of inputs for "center"!!!');    
end


%% Crop volume

% Calculate cropping indices
s = center(:) - floor(crop_size(:)/2);
e = s + crop_size(:) - 1;

% Crop volume
crop_vol = img(s(1):e(1),s(2):e(2));






