function wedge = sg_binary_wedgemask(boxsize,tilts)
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
if numel(boxsize) == 1
    boxsize = ones(1,3).*boxsize;
elseif numel(boxsize) == 2
    error('ACHTUNG!!! Incorrect number of inputs for boxsize!!!');
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
    
end

% Generate binary wedge
wedge = single(permute(repmat(sum_slice > 0,[1,1,boxsize(2)]),[1,3,2]));

    
    

