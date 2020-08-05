function rvol = sg_rotate_vol(vol,eulers,center,mode)
%% sg_rotate_vol
% General wrapper function for performing 3D rotations. By default,
% rotations are linear. Options are 'linear' or 'cubic'.
%
% WW 09-2018

%% Check check

if nargin < 4
    mode = 'linear';
end
if nargin < 3
    center = [];
elseif (nargin ~= 2) && (nargin ~= 4)
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end
    

%% Rotate
switch mode
    case 'linear'
        rvol = sg_rotate_linear(vol,eulers,center);
    case 'cubic'
        rvol = sg_rotate_cubic(vol,eulers,center);
    otherwise
        error('ACHTUNG!!! Unsupported rotation mode!!! Only "linear" or "cubic" supported!!!');
end
