function f = generate_wedgemask_slices(f,boxsize,tilts,bpf,shift)
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
% NOTE: there are a few inconsistent memory leak issues here. There can be
% a leak when generating the slice_idx and when generating the 3D wedge
% weight. This becomes a big issue if you are repeatedly recalculating the
% wedgemasks slices (I found this issue with a mangled motivelist that had
% the tomo_num changing at every entry). In practice, this may not be an
% actual issue; i.e. I haven't figured out how to fix it.
%
% WW 06-2019

%% Check check

% Check for fft-shift
if nargin < 5
    shift = false;
end

% Check for bandpass filter
if nargin < 4
    bpf = ones(boxsize,'single');
end

% Preset binarization cutoff
b_cut = exp(-2);


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
f.slice_idx = cell(n_tilts,1);

% Sum volume
sum_slice= zeros(boxsize([1,3]),'single');

% Loop through tilts
for i = 1:n_tilts
    
    % Rotate slice
    rslice = tom_rotate_mod(slice,tilts(i));
    rslice = single(rslice > b_cut);
    
    % Fourier crop
    if ~square
        rslice = sg_crop_image(fftshift(fft2(rslice)),boxsize([1,3]));
        rslice = real(ifft2(ifftshift(rslice)));
        rslice = single(rslice > b_cut);
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
    f.slice_idx{i} = find(proj > 0); 
    
end


% Generate binary slice
bin_slice = sum_slice > 0;


% Generate slice weight
slice_wei = zeros(boxsize([1,3]),'single');
slice_wei(bin_slice) = 1./sum_slice(bin_slice);


% Generate binary wedge
f.bin_wedge = single(permute(repmat(bin_slice,[1,1,boxsize(2)]),[1,3,2]));


% Generate 3D wedge weight
f.wedge_weight = permute(repmat(slice_wei,[1,1,boxsize(2)]),[1,3,2]);

% Check FFT shift
if shift
    f.bin_wedge = ifftshift(f.bin_wedge);
    f.wedge_weight = ifftshift(f.wedge_weight);
end
   
    
    

