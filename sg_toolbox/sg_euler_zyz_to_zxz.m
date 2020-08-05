function [na1,na2,na3] = sg_euler_zyz_to_zxz(a1,a2,a3)
%% sg_euler_zyz_to_zxz
% Convert a set of ZYZ euler angles to ZXZ using quaternions. Input angles
% are given as rotations 1, 2, and 3; output angles are also given in
% sequential order.
%
% WW 04-2019

%% Convert angles

% Convert input angles to quaternions
q1 = sg_axisangle2quaternion([0,0,1],a1);
q2 = sg_axisangle2quaternion([0,1,0],a2);
q3 = sg_axisangle2quaternion([0,0,1],a3);


% Compose rotations
q = sg_quaternion_multiply(q3,q2,q1);
q = sg_quaternion_normalize(q);


% Reconvert
[na1,na3,na2] = sg_quaternion2euler(q);


