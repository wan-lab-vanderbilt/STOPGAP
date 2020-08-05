function f_idx = calculate_3d_fcrop_idx(full_size,crop_size)
%% calculate_3d_fcrop_idx
% Calculate Fourier indices for 3D cropping.
%
% WW 08-2018

%% Check check

% Check full_size
if numel(full_size) == 1
    full_size = ones(3,1).*full_size;
end

% Check crop_size
if numel(crop_size) == 1
    crop_size = ones(3,1).*crop_size;
end


%% Calculate indices

% Initialize array
f_idx = false(full_size(1),full_size(2),full_size(3));

% Fill crop grid
f_idx(1:crop_size(1),1:crop_size(2),1:crop_size(3)) = true;

% Shift to fftshift positions
halfbox = floor(crop_size./2);
f_idx = circshift(f_idx,[-halfbox(1),-halfbox(2),-halfbox(3)]);



















