function img = sg_apply_2d_ctf(img,defocus,cs,amp_contrast,voltage,apply_type,pixelsize,f)
%% sg_apply_2d_ctf
% Apply a 2D CTF to an image. Defocus is given in microns.
%
% If astigmatism is desired, defocus should be given as an array:
% [defocus 1, defocus 2, astigmatism angle]. Convention for these
% parameters follows Mindell and Grigorieff (2003),
% (doi: 10.1016/S1047-8477(03)00069-8).
%
% For optimal speed, a frequency can be supplied. This should already be
% ifftshifted (zero frequency at 1,1).
%
% Apply type is either 'uncorr' for uncorrected CTF, or 'corr', for
% applying a corrected (absolute value) CTF.
%
% WW 06-2019

%% Check check

% Check for frequency array
if nargin < 8
    f = ifftshift(sg_frequencyarray(img,pixelsize));
end

% Check for phase shift
if numel(defocus) == 4
    pshift = defocus(4);
else
    pshift = 0;
end

% Parse image size
dims = size(img);
cen = floor(dims./2)+1;

%% Calculate defocus array

if numel(defocus) == 3
    
    % Calcualte grid
    x = (1:dims(1)) - cen(1);
    y = (1:dims(2)) - cen(2);
    [xg,yg] = ndgrid(x,y);
    
    % Calculate angle array
    alphag = rot90(atan2(yg,xg).*(180/pi())); 
    
    % Calcuate defocii
    d_sum = defocus(1) + defocus(2);
    d_diff = defocus(1) - defocus(2);
    d = ifftshift((d_sum + d_diff.*cosd(2.*(alphag-astig)))/2);

else
%     d = ones(dims,'single').*defocus;
    d = defocus;
end



%% Calculate and apply ctf

% Calculate CTF
ctf = sg_ctf(d,pshift,amp_contrast,cs,voltage,f);
if strcmp(apply_type,'corr')
    ctf = abs(ctf);
end

% Apply to image
img = real(ifft2(fft2(img).*ctf));







