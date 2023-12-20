function [XYZ] = Rx(XYZ,a,units)

% Rx: Rotate 3D Cartesian coordinates around the X axis
%
% Useage:   [XYZ] = Rx(XYZ,alpha,units)
%
% XYZ is a [3,N] or [N,3] matrix of 3D Cartesian coordinates
%
% 'alpha' - angle of rotation about the X axis
% 'units' - angle is either 'degrees' or 'radians'
%           the default is alpha in radians
% 
% If input XYZ = eye(3), the XYZ returned is
% the rotation matrix.
% 
% See also Ry Rz
%

% Licence:  GNU GPL, no express or implied warranties
% History:  04/2002, Darren.Weber@flinders.edu.au
%                    Developed after example 3.1 of
%                    Mathews & Fink (1999), Numerical
%                    Methods Using Matlab. Prentice Hall: NY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('units','var'), units = 'radians'; end

% convert degrees to radians
if isequal(units,'degrees'),
    a = a*pi/180;
end

Rx = [1 0 0; 0 cos(a) -sin(a); 0 sin(a) cos(a) ];

if isequal(size(XYZ,1),3),
    XYZ = Rx * XYZ;
else
    XYZ = XYZ';
    if isequal(size(XYZ,1),3),
        XYZ = [Rx * XYZ]';
    else
        error('Rx: Input XYZ must be [N,3] or [3,N] matrix.\n');
    end
end

return
