function [axis,angle] = sg_quaternion2axisangle(q)
%% sg_quaternion2axisangle
% A function to convert a quaternion to an axix-angle rotation. Quaternions
% are provided in JPL format: [x,y,z,w].
%
% WW 10-2017

%% Convert!!!!1!

% Normalize input quaternion
q = sg_quaternion_normalize(q);

% Calculate angle
angle = acosd(q(4))*2;

% Calculate denominator for axis calculations
s = sqrt(1-(q(4)^2));

if s < 0.001    % Angle is near zero, which produces a singularity...
    
    x = q(1);
    y = q(2);
    z = q(3);
    
else
    
    x = q(1)/s;
    y = q(2)/s;
    z = q(3)/s;
    
end

% Return axis
axis = [x,y,z];
  
    