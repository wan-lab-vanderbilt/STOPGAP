function crop_vol = sg_crop_volume(vol,crop_size,center)
%% sg_crop_volume
% Crop a volume to 'crop_size' around 'center'. If no center is given,
% the center of the box is used. 
%
% WW 01-2019


%% Check check

% Check for box center
dims = size(vol);
if nargin == 2
    center = floor(dims./2)+1;
end

% Check input vectors
if numel(crop_size) == 1
    crop_size = ones(1,3).*crop_size;
elseif numel(crop_size) ~=3
    error('ACHTUNG!!! Invalid number of inputs for "crop_size"!!!');
end
if numel(center) == 1
    center = ones(3,1).*center;
elseif numel(center) ~=3
    error('ACHTUNG!!! Invalid number of inputs for "center"!!!');    
end


%% Crop volume

% Calculate cropping indices
s = center(:) - floor(crop_size(:)/2);
e = s + crop_size(:) - 1;

% Crop volume
crop_vol = vol(s(1):e(1),s(2):e(2),s(3):e(3));






