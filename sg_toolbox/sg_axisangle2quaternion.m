function q = sg_axisangle2quaternion(axis,angle)
%% sg_axisangle2quaternion
% A function to convert an axis-angle rotation to a rotation quaternion.
%
% Quaternion is in the JPL format: [x,y,z,w];
%
% WW 10-2017

%% Convert!!!

% Normalize axis
n_axis = axis./sqrt(sum(axis.^2));

% Sine of angle
s = sind(angle/2);

% Quaternion
q = zeros(4,1);
q(1:3) = n_axis.*s;
q(4) = cosd(angle/2);
