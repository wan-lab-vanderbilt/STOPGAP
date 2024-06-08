function I = tom_sph2cart(pol)
%TOM_SPH2CART transforms 3D-volumes from polar to cartesian coordinates
%
%   I = tom_sph2cart(pol)
%
%   A 3D-volume I is sampled in spherical coordinates RHO, PHI, THETA. TOM_SPH2CART 
%   samples the data on a cartesian mesh using trilinear interpolation.
%   The dimensions of the polar data POL are the radius R the polar angle
%   PHI, and the azimuthal angle THETA. The dimensions are assumed to be 
%   (NDIMR, 4*NDIMR, 2*NDIMR). The dimensions of I are
%   (2*NDIMR,2*NDIMR,2*NDIMR)
%
%PARAMETERS
%
%  INPUT
%   pol                 3 dim array in spherical coordinates
%  
%  OUTPUT
%   I                   3 dim array in cartesian coordinates
%
%EXAMPLE
%   sph = zeros(16,64,32);
%   sph(8,:,:) = 1;
%   cart = tom_sph2cart(sph);
%   tom_dspcub(cart);
%
%REFERENCES
%
%SEE ALSO
%   TOM_CART2POLAR, TOM_CART2SPH, TOM_POLAR2CART
%
%   created by FF 08/17/03
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

nradius = size(pol,1);nphi=size(pol,2);ntheta=size(pol,3);
nx = ntheta;ny = ntheta;nz = ntheta;
[x,y,z] = ndgrid(-nradius:nradius-1,-nradius:nradius-1,-nradius:nradius-1);
[r phi theta] = ndgrid(0:nradius-1,0:2*pi/nphi:2*pi-2*pi/nphi,0:pi/(ntheta-1):pi);
% polar coordinates in cartesian space
%eps = 10^(-12);%added due to numerical trouble with floor
eps = 0;
% index field R
cr = sqrt(x.^2+y.^2+z.^2)+1;
%index field phi
cphi = atan2(y,x);
indx = find( cphi < 0);
cphi(indx) = 2*pi-abs(cphi(indx));
cphi=cphi/(2*pi)*nphi+1;
%index field theta
ctheta = atan2(sqrt(y.^2+x.^2),z);
ctheta=ctheta/pi*(ntheta-1)+1;
% extend periodically in phi - 360 deg == 0 deg
pol(:,nphi+1,:)=pol(:,1,:);
% extend in R - cheap version - pad zeros
pol(nradius:ceil(nradius*sqrt(3)+1),:,:)=0;
nradius=size(pol,1);
nphi = nphi +1;
clear x y z; 
%%%%%%%%%%%%%% trilinear interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate levers
tr = cr-floor(cr);
tphi = cphi-floor(cphi);
ttheta = ctheta-floor(ctheta);
%perform interpolation
I = (1-tr).*(1-tphi).*(1-ttheta).*pol(floor(cr)+nradius*(floor(cphi)-1)+nphi*nradius*(floor(ctheta)-1)) + ...
    (tr).*(1-tphi).*(1-ttheta).*pol(ceil(cr)+nradius*(floor(cphi)-1)+nphi*nradius*(floor(ctheta)-1)) + ...
    (1-tr).*(tphi).*(1-ttheta).*pol(floor(cr)+nradius*(ceil(cphi)-1)+nphi*nradius*(floor(ctheta)-1)) + ...
    (1-tr).*(1-tphi).*(ttheta).*pol(floor(cr)+nradius*(floor(cphi)-1)+nphi*nradius*(ceil(ctheta)-1)) + ...
    (tr).*(tphi).*(1-ttheta).*pol(ceil(cr)+nradius*(ceil(cphi)-1)+nphi*nradius*(floor(ctheta)-1)) + ...
    (tr).*(1-tphi).*(ttheta).*pol(ceil(cr)+nradius*(floor(cphi)-1)+nphi*nradius*(ceil(ctheta)-1)) + ...
    (1-tr).*(tphi).*(ttheta).*pol(floor(cr)+nradius*(ceil(cphi)-1)+nphi*nradius*(ceil(ctheta)-1)) + ...
    (tr).*(tphi).*(ttheta).*pol(ceil(cr)+nradius*(ceil(cphi)-1)+nphi*nradius*(ceil(ctheta)-1));