function filt_vol = sg_lowpass_filter(vol, pixelsize,resolution)
%% sg_lowpass_filter
% Apply a lowpass filter to a volume to reach a target resolution. Only
% works on cubic volumes.
%
% WW 09-2018

%% Filter!!!

% Determine size of volume
boxsize = size(vol,1);

% Caclulate resolution cutoff in Fourier space
r_cut = round((boxsize*pixelsize)/resolution);

% Calculate filter
filter = ifftshift(tom_sphere([boxsize,boxsize,boxsize],r_cut));

% Apply filter
filt_vol = real(ifftn(fftn(vol).*filter));


