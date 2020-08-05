function [peak,shift] = fourier_subpixel_peak(map, supersample)
%% fourier_subpixel_peak
% Determine a subpixel peak position by supersampling in Fourier space. 
%
% WW 07-2018

%% Find subpixel peak


% Initial peak position
[~, idx] = max(map(:));
[x,y,z] = ind2sub(size(map),idx);
cen = floor(size(map,1)/2)+1;


% Crop peak
crop_peak = map(x-1:x+1,y-1:y+1,z-1:z+1);
ft_crop_peak = fftshift(fftn(crop_peak));

% Padding coordinates
ss_size = supersample*3;
cen2 = floor(ss_size/2)+1;
p1 = ceil((ss_size-3)/2)+1;
p2 = p1 +2;

% Super-sample volume
ss_ft_peak = zeros(ss_size,ss_size,ss_size);
ss_ft_peak(p1:p2,p1:p2,p1:p2) = ft_crop_peak;
ss_peak =real(ifftn(ifftshift(ss_ft_peak)));

% Find supersampling peak
[peak, idx2] = max(ss_peak(:));
[subx,suby,subz] = ind2sub(size(ss_peak),idx2);

% Rescale super-sample pixels
sx = (subx - cen2)/supersample;
sy = (suby - cen2)/supersample;
sz = (subz - cen2)/supersample;

% Calculate shift
shift = [x-cen+sx,y-cen+sy,z-cen+sz];

% Rescale peak value
peak = peak*(supersample^3);

