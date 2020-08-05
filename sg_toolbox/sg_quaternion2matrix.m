function mat = sg_quaternion2matrix(q)
%% sg_quaternion2matrix
% A function to convert a quaternion to a rotation matrix. The quaternion
% should be supplied in JPL format [x,y,z,w].
%
% WW 10-2017

%% Convert!!1!

% Initialize and fill rotation matrix
mat = zeros(3,3);
mat(1) = 1-(2*((q(2)^2)+(q(3)^2)));
mat(2) = (2*q(1)*q(2)) + (2*q(4)*q(3));
mat(3) = (2*q(1)*q(3)) - (2*q(4)*q(2));
mat(4) = (2*q(1)*q(2)) - (2*q(4)*q(3));
mat(5) = 1-(2*((q(1)^2)+(q(3)^2)));
mat(6) = (2*q(2)*q(3)) + (2*q(4)*q(1));
mat(7) = (2*q(1)*q(3)) + (2*q(4)*q(2));
mat(8) = (2*q(2)*q(3)) - (2*q(4)*q(1));
mat(9) = 1-(2*((q(1)^2)+(q(2)^2)));


