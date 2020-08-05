function [phi, psi, the] = sg_matrix2euler(mat)
%% sg_matrix2euler
% A function to convert a 3x3 rotation matrix to a set of Euler angles. The
% Euler angles follow the TOM Z-X-Z and phi, psi, theta conventions. The
% mathematical derivation of this function follows that of
% dynamo_matrix2euler.
%
% WW 10-2017

%% Convert!
tol=1e-4;

%warning('indetematination in defining narot and tdrot: rotation about z');

% mat(3,3) ~= -1
if abs(mat(3,3)-1)<tol;
    the=0;
    psi=atan2(mat(2,1),mat(1,1))*180/pi;
    phi=0;
    return
end

% mat(3,3) ~= -1
if abs(mat(3,3)+1)<tol;
    phi=0;
    the=180;
    psi=atan2(mat(2,1),mat(1,1))*180/pi;
    
    return
end

 
% General case 

phi  = atan2d(mat(3,1),mat(3,2));
the   = acosd(mat(3,3));
psi  = atan2d(mat(1,3),-mat(2,3));




