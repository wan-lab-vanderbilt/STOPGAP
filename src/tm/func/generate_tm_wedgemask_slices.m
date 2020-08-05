function f = generate_tm_wedgemask_slices(o,f)
%% generate_tm_wedgemask_slices
% A function to generate slice-type wedgemasks for template matching.
%
% WW 01-2019

%% Initialize

% Parse tilt angles
tilt_angle = o.wedgelist(f.wedge_idx).tilt_angle;
n_tilts = numel(tilt_angle);

% Calculate maximum sizes
max_tile = max(o.tilesize([1,3]));
max_tile_cen = floor(max_tile/2)+1;

% Generate 2D slice image
img = zeros(max_tile,max_tile,'single');
img(:,max_tile_cen) = 1;

% Linear bandpass indices
bpf_idx = o.tmpl_bpf(:) > 0;

% Initialize slices
f.slice_idx = cell(n_tilts,1);

% Weight
f.slice_weight = zeros([o.tmpl_size,o.tmpl_size,o.tmpl_size],'single');
weight = zeros(o.tmpl_size^3,1,'single');

% 2D tile filter
tile_bin_slice = zeros(o.tilesize([1,3]),'single');



%% Find indices for each slice

for i = 1:n_tilts
    
    % Rotate 2D image
    r_img = tom_rotate(img,tilt_angle(i));
    
    %%%%% Generate Template Filter %%%%%
    
    % Crop 2D image
    crop_r_img = single(sg_crop_image(r_img,[o.tmpl_size,o.tmpl_size]) > exp(-2));

    % 3D slice
    slice_vol = ifftshift(permute(repmat(crop_r_img,[1,1,o.tmpl_size]),[1,3,2]));
    
    % Indices
    slice_idx = slice_vol(:) & bpf_idx;
    
    % Add to weights
    weight = weight + slice_idx;
    
    % Store indices
    f.slice_idx{i} = find(slice_idx);
    
    
    %%%%% Generate Tile Filter %%%%%
    
    % Rescale 2D image
    r_img = fftshift(fft2(r_img));
    new_img = real(ifft2(ifftshift(sg_crop_image(r_img,o.tilesize([1,3])))));
    new_img = new_img./max(new_img(:));

    % Binarize image
    new_img = single(new_img > exp(-2));
    tile_bin_slice = tile_bin_slice + new_img;
    
    
end

% Generate tile binary wedge filter
tile_bin_slice = single(tile_bin_slice > 0);
f.tile_bin_wedge = ifftshift(permute(repmat(tile_bin_slice,[1,1,o.tilesize(2)]),[1,3,2]));


%% Generate reweighting filter

% Reshape weight as 3D-volume
weight = reshape(weight,[o.tmpl_size,o.tmpl_size,o.tmpl_size]);

% Non-zero indices
w_idx = (weight > 0);

% Invert values for filter
f.slice_weight(w_idx) = 1./weight(w_idx);


%% Generate binary mask

% Get binary mask
f.bin_wedge = single(w_idx);






