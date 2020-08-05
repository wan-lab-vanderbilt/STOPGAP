function out=tom_rotate(varargin)
%
% TOM_ROTATE performs a 2d or 3d rotation, depending on the input 
%
%   TOM_ROTATE performs a rotation using bi- or trilinear interpolation. In
%   3D the rotation is performed around the Euler angles denoted phi, psi
%   and theta. The definition is the following:
%   The object is rotated by PSI counterclockwise around the Z-axis. Then
%   the object is rotated by THETA around the NEW Y-axis. Finally, a
%   rotation around by PHI the NEW Z-axis is performed. So take care: In
%   some programs THETA is defined as a rotation around X -- here it is
%   Y!!!
%
%   The three rotation  angles  correspond  to
%   the definition of Euler angles. This means that  a  rotation  with
%   angle alpha about the:
%       X-axis  corresponds to  phi=0     psi=0   the=alpha
%       Y-axis  corresponds to  phi=270   psi=90  the=alpha
%       Z-axis  corresponds to  phi=alpha psi=0   the=0
%   When viewed in the direction of the positive  axes,  the  rotation
%   resulting with positive alpha is in the  sense  of a  right-handed
%   screw.
%
%   Note: This function works as an interface. The actual computation is done
%         in the C-Function tom_rotatec
%
% Syntax:
%   out=tom_rotate(in,[angle(s)],interp,[center]) 
%
% Input:
%   in                    :image or Volume as single !
%   angle(s)              :in=image  rotation angle
%                         :in=volume euler Angles [phi psi theta] 
%   interp                :interpolation only 'linear' implemented                     
%   center(optional)      :in=image  [centerX centerY]       
%                         :in=Volume [centerX centerY centerZ]
% Ouput:
%   out                   : Image rotated
%
% Example:
% im=tom_emread('pyrodictium_1.em');
% out=tom_rotate(single(im.Value),40,'linear',[256 256]);
%
% im=tom_emread('testvol.em');
% im=single(im.Value);
% out=tom_rotate(im,[30 20 95],'linear');
%       
%  12/04/04 FB
%   last change: 26/10/04 FF
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom



switch nargin
    case 4,
        center = varargin{4};
        ip=varargin{3};
    case 3,
        ip=varargin{3};
        center = [floor(size(varargin{1})./2)];%bug fixed for odd dims - FF
    case 2,
        center = [floor(size(varargin{1})./2)];%bug fixed FF
        ip = 'linear';
    otherwise
        disp('wrong number of Arguments');
        out=-1; return;
end;
%parse inputs
in = varargin{1};
euler_angles=varargin{2};


% allocate some momory 
out = single(zeros(size(in))); 

% call C-Function to do the calculations
tom_rotatec(single(in),out,single([euler_angles]),ip,single([center]));

out = double(out);
