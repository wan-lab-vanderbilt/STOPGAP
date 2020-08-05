function [phi,psi,the] = sg_quaternion2euler(q)
%% sg_quaternion2euler
% A function to take an input quaternion in the JPL notation [x,y,z,w], and
% return Euler angles in the TOM/AV3 format, i.e. [phi,psi,theta], where
% the rotation order is phi-theta-psi around ZXZ axes. 
%
% This conversion approach fails close to a singularity, i.e. when theta is
% near 0 or 180 degrees. In such cases, this script converts the quaternion
% to a rotation matrix, then to Euler angles. 
%
% WW 10-2017

%% Convert!

% Quaternion conversion
psi=atan2d((q(1).*q(3)+q(2).*q(4)),(q(1).*q(4)-q(2).*q(3)));
the=acosd(q(4).^2-q(1).^2-q(2).^2+q(3).^2);
phi=atan2d((q(1).*q(3)-q(2).*q(4)),(q(1).*q(4)+q(2).*q(3)));

% Singularity check
sing_chk = (abs(the)<0.1) || (abs(the-180)<0.1) || (abs(the-360)<0.1);
if sing_chk
    disp('Achtung!!! Output Euler is close to a singularity');
    % Convert to matrix, then to Eulers
    mat = sg_quaternion2matrix(q);
    [phi,psi,the] = sg_matrix2euler(mat);
end
