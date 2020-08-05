function q = sg_euler2quaternion(phi,psi,the)
%% sg_euler2quaternion
% A function to convert a TOM/AV3 style Euler angle set to a quaternion.
% Quaternions are in the JPL format: [x,y,z,w]. The Euler angles follow the
% TOM/AV3 standard of phi-theta-psi, ZXZ rotations.
%
% WW 10-2017

%% Convert!!!

% Generate quaternions for each rotation
q_phi = sg_axisangle2quaternion([0,0,1],phi);
q_psi = sg_axisangle2quaternion([0,0,1],psi);
q_the = sg_axisangle2quaternion([1,0,0],the);

% Compose rotations
q = sg_quaternion_multiply(q_psi,q_the,q_phi);
q = sg_quaternion_normalize(q);


