function [bin_wedge, wedge_weight, slice_idx] = generate_wedgemask_slices(boxsize,tilts,bpf,shift)
%% generate_wedgemask_slices
% Generate wedgemasks as a set of 2D-slices. Input parametes are input
% boxsize, input tilt-angles, bandpass filter, and whether to apply an
% fftshift.
%
% If a bandpass filter is supplied, the slice indices will with respect to
% the masked-in regions. The bandpass filter is assumed to be fftshifted
% in the same way as the 'shift' input. 
%
% For non-cubic volumes, the XZ-slices are calculated using the largest
% dimension and Fourier cropped to the non-square size. 
%
% WW 06-2019

%% Check check

% Check for fft-shift
if nargin < 4
    shift = false;
end

% Check for bandpass filter
if nargin < 3
    bpf = ones(boxsize,'single');
end

%% Generate XZ-slice

% Check XZ agreement
square = boxsize(1) == boxsize(3);

% Parse largest XZ dimension
max_xz = max(boxsize([1,3]));

% Generate slice
slice = zeros(max_xz,max_xz,'single');
slice(:,floor(max_xz/2)+1) = 1;


%% Generate slices

% Number of tilts
n_tilts = numel(tilts);

% Slice indices
slice_idx = cell(n_tilts,1);

% Sum volume
sum_slice= zeros(boxsize([1,3]),'single');

% Loop through tilts
for i = 1:n_tilts
    
    % Rotate slice
    rslice = tom_rotate(slice,tilts(i));
    rslice = single(rslice>exp(-2));
    
    % Fourier crop
    if ~square
        rslice = sg_crop_image(fftshift(fft2(rslice)),boxsize([1,3]));
        rslice = real(ifft2(ifftshift(rslice)));
        rslice = single(rslice>exp(-2));
    end
    
    % Sum slice
    sum_slice = sum_slice + rslice;
    
    % Generate 3D slice
    proj = permute(repmat(rslice,[1,1,boxsize(2)]),[1,3,2]);
    
    % FFT shift
    if shift
        proj = ifftshift(proj);
    end
    
    % Apply bandpass
    proj = proj.*bpf;
    
    % Save indices
    slice_idx{i} = find(proj > 0); 
    
end


% Generate binary slice
bin_slice = sum_slice > 0;


% Generate slice weight
slice_wei = zeros(boxsize([1,3]),'single');
slice_wei(bin_slice) = 1./sum_slice(bin_slice);


% Generate binary wedge
bin_wedge = single(permute(repmat(bin_slice,[1,1,boxsize(2)]),[1,3,2]));

% Generate 3D wedge weight
wedge_weight = permute(repmat(slice_wei,[1,1,boxsize(2)]),[1,3,2]);

% Check FFT shift
if shift
    bin_wedge = ifftshift(bin_wedge);
    wedge_weight = ifftshift(wedge_weight);
end
    
    
    

