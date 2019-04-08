function cropped_volume = crop_volume(volume, crop_size)
%% crop_volume
% A function to crop a volume from the center.
%
% WW 04-2018

%% Check check

if numel(crop_size) == 1
    crop_size = repmat(crop_size,[3,1]);
elseif crop_size ~= 3
    error('ACHTUNG!!! crop_size is given as either a single number or a triplet!!!');
end

%% Crop!!!!

% Boxsize of input volume
boxsize = size(volume);

% Calculate crop start and end
idx = zeros(3,2);
for i = 1:3
    idx(i,1) = ((boxsize(i)-crop_size(i))/2)+1;
    idx(i,2) = idx(i,1) + crop_size(i) - 1;
end

% Crop volume
cropped_volume = volume(idx(1,1):idx(1,2),idx(2,1):idx(2,2),idx(3,1):idx(3,2));


