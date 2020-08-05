function [crop_boxsize, fcrop] = determine_fcrop_size_from_bpf(bpf)
%% determine_fcrop_size_from_bpf
% Determine the size of the Fourier cropped volume by finding the cutoffs
% of the bandpass filters. Input bandpass filter is assumed to be
% fftshifted.
%
% If the edge of the bandpass filter is beyond 2/3 Nyquist of the full box,
% the full boxsize is returned. Otherwise, the edge of the filter is set at
% 2/3 Nyquist.
%
% WW 03-2019


%% Calculate fcrop size

% Size of filter
dims = size(bpf);



% Coordinate radii
x_filt = squeeze(bpf(1:dims(1)/2,1,1));
y_filt = squeeze(bpf(1,1:dims(2)/2,1));
z_filt = squeeze(bpf(1,1,1:dims(3)/2));


% New boxsize
new_boxsize = zeros(1,3);
new_boxsize(1) = ceil((find(x_filt>0,1,'last')+1)*(3/2))*2;
new_boxsize(2) = ceil((find(y_filt>0,1,'last')+1)*(3/2))*2;
new_boxsize(3) = ceil((find(z_filt>0,1,'last')+1)*(3/2))*2;


% Return boxsize
if any(new_boxsize >= dims)
    crop_boxsize = dims;
    fcrop = false;
else
    crop_boxsize = new_boxsize;
    fcrop = true;
end


