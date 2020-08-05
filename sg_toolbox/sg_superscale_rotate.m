function crop_rvol = sg_superscale_rotate(vol,eulers,scaling,center,mode)
%% sg_superscale_rotate
% A function for rotate a volume with super scaling. This is performed by
% first Fourier padding the volume, rotating the superscaled volume, and
% Fourier cropping the rotated volume to return a volume the same size as 
% the input volume. 
%
% WW 11-2018

%% Check check

if nargin < 5
    mode = 'linear';
end
if nargin < 4
    center = [];
elseif (nargin ~= 3) && (nargin ~= 5)
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end

if scaling < 1
    error('ACHTUNG!!! Scaling is set under 1... ');
elseif scaling == 1
    error('ACHTUNG!!! Scaling was set to 1...');
end
    
    

%% Upscale, rotate, and downscale

% Upscale by Fourier padding
ssvol = sg_fourier_rescale_volume(vol,scaling);

% Rotate
switch mode
    case 'linear'
        rvol = sg_rotate_linear(ssvol,eulers,center);
    case 'cubic'
        rvol = sg_rotate_cubic(ssvol,eulers,center);
    otherwise
        error('ACHTUNG!!! Unsupported rotation mode!!! Only "linear" or "cubic" supported!!!');
end

% Downscale
crop_rvol = sg_fourier_rescale_volume(rvol,1/scaling);



