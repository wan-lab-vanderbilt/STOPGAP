function pol = tom_cart2polar(I)
%TOM_CART2POLAR transforms 2D-images from cartesian to polar coordinates
%
%   pol = tom_cart2polar(I)
%
%PARAMETERS
%
%  INPUT
%   I                   2 dim array
%  
%  OUTPUT
%   pol                 2 dim array in polar coordinates
%
%EXAMPLE
%   cart = zeros(32,32);
%   cart(8,8) = 1;
%   cart = tom_symref2d(cart,4);
%   pol = tom_cart2polar(cart);
%   imagesc(pol');
%
%REFERENCES
%
%SEE ALSO
%   TOM_POLAR2CART, TOM_CART2SPH, TOM_SPH2CART
%
%   created by FF 08/17/03
%   profiled and optimized by AK 09/08/07
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

nx = size(I,1);ny = size(I,2);nz = size(I,3);
if nz > 1
    error(' use for tom_cart2sph for 3D arrays!')
end;
nradius = max(nx,ny)/2;
nphi = 4*nradius;
[r phi] = ndgrid(0:nradius-1,0:2*pi/nphi:2*pi-2*pi/nphi);
% polar coordinates in cartesian space
%eps = 10^(-12);%added due to numerical trouble with floor
eps = 0;
px = r.*cos(phi)+nradius+1+eps;
py = r.*sin(phi)+nradius+1+eps;
clear r phi ; 
%%%%%%%%%%%%%% bilinear interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate levers
fpx = floor(px);
fpy = floor(py);
cpx = ceil(px);
cpy = ceil(py);
tx = px-fpx;
ty = py-fpy;

%perform interpolation
%   check for undefined indexes
%mxx = max(max(floor(px+1)));
%if  mxx > nx
%    I(mxx,ny) =0;
%    nx = mxx;
%end;
%mxy = max(max(floor(py+1)));
%if mxy > ny
%    I(nx,mxy)=0;
%    ny = mxy;
%end;    
%pol = (1-tx).*(1-ty).*I(floor(px)+nx*(floor(py)-1)) + ...
%    (tx).*(1-ty).*I(floor(px+1)+nx*(floor(py)-1)) + ...
%    (1-tx).*(ty).*I(floor(px)+nx*(floor(py+1)-1)) + ...
%    (tx).*(ty).*I(floor(px+1)+nx*(floor(py+1)-1));
pol = (1-tx).*(1-ty).*I(fpx+nx*(fpy-1)) + ...
    (tx).*(1-ty).*I(cpx+nx*(fpy-1)) + ...
    (1-tx).*(ty).*I(fpx+nx*(cpy-1)) + ...
    (tx).*(ty).*I(cpx+nx*(cpy-1));

% an alternative using tform (SN):
%
% function pol = cart2polar(in) 
% 
% tform = maketform ('custom', 2, 2, @cart2polar, @polar2cart, size(in)); 
% pol = imtransform(in, tform, 'cubic', 'XData',[0 2.*pi],'YData', [1 size(in,1)./2],'Size', [size(in,1)./2 size(in,2).*2]);
% 
% function U = polar2cart(X, T)
% U(:,1)= X(:,2) .* sin(X(:,1)) + T.tdata(2)./2+1; 
% U(:,2)= X(:,2) .* cos(X(:,1)) + T.tdata(1)./2+1;
