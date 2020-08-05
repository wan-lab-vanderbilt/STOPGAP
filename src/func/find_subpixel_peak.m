function [coord, I] = find_subpixel_peak(vol,mask)
%% find_subpixel_peak
% A function to take in a given volume, find the pixel with highest value 
% within a mask, and use interpolation to find the peak with subpixel 
% precision. The interpolation is performed on the unmasked volume to
% prevent edge artifacts.
%
% WW 02-2012


%% Find initial peak

% Apply mask
if nargin == 2
    vol = vol.*mask;
end

% Initial peak position
[peak, idx] = max(vol(:));
[x,y,z] = ind2sub(size(vol),idx);


%% Caculate subpixel position

try    
    dx = (vol(x+1,y,z) - vol(x-1,y,z))/2;
    dy = (vol(x,y+1,z) - vol(x,y-1,z))/2;
    dz = (vol(x,y,z+1) - vol(x,y,z-1))/2;

    dxx = vol(x+1,y,z) + vol(x-1,y,z) - 2*peak;
    dyy = vol(x,y+1,z) + vol(x,y-1,z) - 2*peak;
    dzz = vol(x,y,z+1) + vol(x,y,z-1) - 2*peak;

    dxy = (vol(x+1,y+1,z) + vol(x-1,y-1,z) - vol(x+1,y-1,z) - vol(x-1,y+1,z))/4;
    dxz = (vol(x+1,y,z+1) + vol(x-1,y,z-1) - vol(x+1,y,z-1) - vol(x-1,y,z+1))/4;
    dyz = (vol(x,y+1,z+1) + vol(x,y-1,z-1) - vol(x,y-1,z+1) - vol(x,y+1,z-1))/4;


    aa = [dxx,dxy,dxz; dxy,dyy,dyz; dxz,dyz,dzz];
    bb = [-dx; -dy; -dz];

    det = linsolve(aa,bb);
    detx = det(1);
    dety = det(2);
    detz = det(3);
    
    if (abs(detx)>1) || (abs(dety)>1) || (abs(detz)>1) 
        
        coord = [x,y,z];
        I = peak;
        
    else
        
    
        I = peak + dx*detx + dy*dety + dz*detz + dxx*(detx^2)/2 ...
        + dyy*(dety^2)/2 + dzz*(detz^2)/2 + detx*dety*dxy ...
        + detx*detz*dxz + dety*detz*dyz;

        coord = [x+detx, y+dety, z+detz];
        
    end

catch
    
    coord = [x,y,z];
    I=peak;
    
end


    

 















