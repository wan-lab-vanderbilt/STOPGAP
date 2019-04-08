function f = generate_wedgemask_slices(o,f,mode)
%% generate_wedgemask_slices
% A function to generate wedgemasks slices. It returns a set of slice
% indices, which can be used for generating localized slice filters. It
% also retursn a slice_weight, which is used for reweighting areas sampled
% by multiple tilts, and a binary mask. 
%
% WW 01-2018

%% Initialize

% Parse wedge index
w = f.wedge_idx;

% Number of tilts
n_tilts = numel(o.wedgelist(w).wedge_angles);

% Generate 2D slice image
img = zeros(o.boxsize,o.boxsize);
img(:,o.cen) = 1;

% Linear bandpass indices
if strcmp(mode,'align')
    bpf_idx = o.bandpass(:) > 0;
elseif strcmp(mode,'aver')
    bpf_idx = true(o.boxsize^3,1);
end

% Initialize slices
f.slice_idx = cell(n_tilts,1);

% Weight
f.slice_weight = zeros(o.boxsize,o.boxsize,o.boxsize);
weight = zeros(o.boxsize^3,1);

%% Find indices for each slice

for i = 1:n_tilts
    
    % Rotate 2D image
    r_img = tom_rotate(img,o.wedgelist(w).wedge_angles(i)) >= 0.5;
    
    % 3D slice
    slice_vol = permute(repmat(r_img,[1,1,o.boxsize]),[1,3,2]);
    if strcmp(mode,'align')
        slice_vol = ifftshift(slice_vol);
    end
    
    % Indices
    temp_slice_idx = slice_vol(:) & bpf_idx;
    
    % Add to weights
    weight = weight + temp_slice_idx;
    
    % Store indices
    f.slice_idx{i} = find(temp_slice_idx);
    
end

%% Generate reweighting filter

% Reshape weight as 3D-volume
weight = reshape(weight,[o.boxsize,o.boxsize,o.boxsize]);

% Non-zero indices
w_idx = (weight > 0);

% Invert values for filter
f.slice_weight(w_idx) = 1./weight(w_idx);



%% Generate binary mask

% Get binary mask
f.bin_wedge = double(w_idx);



