function padded_volume = pad_volume(volume,pad_size)
%% pad_volume
% A function to pad a volume, placing in into the center of a new box.
%
% WW 04-2018


%% Check check

if numel(pad_size) == 1
    pad_size = repmat(pad_size,[1,3]);
elseif pad_size ~= 3
    error('ACHTUNG!!! crop_size is given as either a single number or a triplet!!!');
end

%% Crop!!!!

% Boxsize of input volume
boxsize = size(volume);

% Calculate crop start and end
idx = zeros(3,2);
for i = 1:3
    idx(i,1) = ((pad_size(i)-boxsize(i))/2)+1;
    idx(i,2) = idx(i,1) + boxsize(i) - 1;
end

% Pad volume
padded_volume = zeros(pad_size);
padded_volume(idx(1,1):idx(1,2),idx(2,1):idx(2,2),idx(3,1):idx(3,2)) = volume;

